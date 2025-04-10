import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class CourtsManager: ObservableObject {
    @Published private(set) var courts: [Court] = []
    @Published var favoriteCourts: [Court] = []
    private let placesService = PlacesService()
    private var lastUpdateTime: Date?
    private static let cacheTimeout: TimeInterval = 30 * 60 // 30 minutes
    public static let maxFavorites = 15

    private let db = Firestore.firestore()
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var currentUserID: String?

    private let queue = DispatchQueue(label: "com.courtfinder.courtsmanager", qos: .userInitiated)

    init() {
        setupAuthListener()
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
            fetchFavoriteCourts()
            // Clean up any duplicate favorites
            Task {
                await cleanupDuplicateFavorites()
            }
        }
    }

    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Removed auth listener")
        }
    }

    private func setupAuthListener() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                if self.currentUserID != user.uid {
                    print("Auth state change: User logged in - \(user.uid)")
                    self.currentUserID = user.uid
                    self.fetchFavoriteCourts()
                }
            } else {
                print("Auth state change: User logged out")
                self.currentUserID = nil
                DispatchQueue.main.async {
                    self.clearFavorites()
                }
            }
        }
    }

    public func isMaxFavoritesReached() -> Bool {
        return favoriteCourts.count >= Self.maxFavorites
    }

    public func fetchFavoriteCourts() {
        guard let userID = currentUserID else {
            print("Cannot fetch favorites: No user ID")
            clearFavorites()
            return
        }

        let userDocRef = db.collection("users").document(userID)

        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching favorites: \(error.localizedDescription)")
                    self.clearFavorites()
                    return
                }

                guard let document = document, document.exists,
                      let data = document.data(),
                      let favoriteCourtsData = data["favoriteCourts"] as? [[String: Any]] else {
                    print("No favorites found for user")
                    self.clearFavorites()
                    return
                }

                do {
                    // Decode the favorite courts from Firestore data
                    let jsonData = try JSONSerialization.data(withJSONObject: favoriteCourtsData)
                    let decoder = JSONDecoder()
                    let fetchedFavoriteCourts = try decoder.decode([Court].self, from: jsonData)
                    
                    // Deduplicate favorites based on place_id
                    let uniqueFavorites = Dictionary(
                        grouping: fetchedFavoriteCourts,
                        by: { $0.place_id }
                    ).compactMapValues { (courts: [Court]) -> Court? in
                        // For each group of courts with the same place_id, take the first one
                        guard let court = courts.first else { return nil }
                        var mutableCourt = court
                        mutableCourt.isFavorite = true
                        return mutableCourt
                    }.values.sorted { (lhs: Court, rhs: Court) -> Bool in
                        lhs.name < rhs.name
                    } // Sort by name for consistency
                    
                    // Update the favorite courts list
                    self.favoriteCourts = Array(uniqueFavorites)
                    
                    // Extract all favorite court IDs for checking
                    let favoriteIDs = self.favoriteCourts.map { $0.place_id }
                    
                    // Update isFavorite status in main courts list
                    self.courts = self.courts.map { court in
                        var mutableCourt = court
                        mutableCourt.isFavorite = favoriteIDs.contains(court.place_id)
                        return mutableCourt
                    }
                    
//                    print("Fetched \(self.favoriteCourts.count) favorite courts")
                } catch {
                    print("Error decoding favorite courts: \(error.localizedDescription)")
                    self.clearFavorites()
                }
            }
        }
    }

    private func clearFavorites() {
        // Clear isFavorite status in main courts list
        self.courts = self.courts.map { court in
            var mutableCourt = court
            mutableCourt.isFavorite = false
            return mutableCourt
        }
        self.favoriteCourts = []
    }

    func fetchCourtsIfNeeded(location: CLLocation) {
        queue.async { [weak self] in
            guard let self = self else { return }

            if let lastUpdate = self.lastUpdateTime {
                let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
                if timeSinceLastUpdate < Self.cacheTimeout {
                    print("📍 Using cached data (updated \(Int(timeSinceLastUpdate/60))m ago)")
                    return
                }
            }

            print("🔄 Fetching fresh courts data...")
            self.placesService.fetchNearbyCourts(location: location) { [weak self] newCourts in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.courts = newCourts
                    // After fetching new courts, update their favorite status
                    if let userID = self.currentUserID {
                        self.fetchFavoriteCourts()
                    }
                    self.lastUpdateTime = Date()
                }
            }
        }
    }

    func toggleFavorite(_ court: Court) async {
        guard let userID = currentUserID else {
            print("Error: Cannot toggle favorite, no user logged in.")
            return
        }

        let userDocRef = db.collection("users").document(userID)
        // Check if the court is actually in favorites rather than rely on isFavorite flag
        let isCurrentlyFavorite = favoriteCourts.contains { $0.place_id == court.place_id }

        do {
            if isCurrentlyFavorite {
                // Remove from favorites - filter out the court with matching place_id
                let updatedFavorites = favoriteCourts.filter { $0.place_id != court.place_id }
                let favoriteDicts = try updatedFavorites.map { try $0.toDictionary() }
                try await userDocRef.updateData([
                    "favoriteCourts": favoriteDicts
                ])
                print("Removed favorite: \(court.place_id)")
            } else {
                // Check if max favorites reached
                if isMaxFavoritesReached() {
                    print("Maximum number of favorites (\(Self.maxFavorites)) reached")
                    return
                }
                
                // Check if court is already in favorites to prevent duplicates
                if !favoriteCourts.contains(where: { $0.place_id == court.place_id }) {
                    // Create a new court with isFavorite set to true
                    var favoriteableCourt = court
                    favoriteableCourt.isFavorite = true
                    
                    // Add to favorites
                    var updatedFavorites = favoriteCourts
                    updatedFavorites.append(favoriteableCourt)
                    let favoriteDicts = try updatedFavorites.map { try $0.toDictionary() }
                    try await userDocRef.setData([
                        "favoriteCourts": favoriteDicts
                    ], merge: true)
                    print("Added favorite: \(court.place_id)")
                } else {
                    print("Court is already in favorites: \(court.place_id)")
                }
            }

            // Update local state after successful Firestore update
            DispatchQueue.main.async {
                // Update isFavorite status in main courts list
                self.courts = self.courts.map { currCourt in
                    var mutableCourt = currCourt
                    if currCourt.place_id == court.place_id {
                        mutableCourt.isFavorite = !isCurrentlyFavorite
                    }
                    return mutableCourt
                }

                // Update favoriteCourts list
                if isCurrentlyFavorite {
                    self.favoriteCourts.removeAll { $0.place_id == court.place_id }
                } else if !self.favoriteCourts.contains(where: { $0.place_id == court.place_id }) {
                    // Only add if not already present
                    var favoritedCourt = court
                    favoritedCourt.isFavorite = true
                    self.favoriteCourts.append(favoritedCourt)
                }
                
                // Notify observers that the favorite courts have changed
                self.objectWillChange.send()
            }
        } catch {
            print("Error toggling favorite: \(error.localizedDescription)")
        }
    }

    func isCourtFavorited(_ courtID: String) -> Bool {
        return favoriteCourts.contains { $0.place_id == courtID }
    }

    func clearCache() {
        queue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.courts = []
                self.lastUpdateTime = nil
                print("🗑️ Cache cleared (courts list only)")
            }
        }
    }

    // Add a method to clean up duplicate favorites
    func cleanupDuplicateFavorites() async {
        guard !favoriteCourts.isEmpty, let userID = currentUserID else { return }
        
        // Check if there are any duplicates
        let courtIDs = favoriteCourts.map { $0.place_id }
        let uniqueIDs = Set(courtIDs)
        
        // If the count is the same, there are no duplicates
        if courtIDs.count == uniqueIDs.count { return }
        
        print("Found duplicate favorites, cleaning up...")
        
        // Create a deduplicated list
        let uniqueFavorites = Dictionary(
            grouping: favoriteCourts,
            by: { $0.place_id }
        ).compactMapValues { (courts: [Court]) -> Court? in 
            courts.first 
        }.values.sorted { (lhs: Court, rhs: Court) -> Bool in
            lhs.name < rhs.name
        }
        
        do {
            // Update Firestore with the deduplicated list
            let userDocRef = db.collection("users").document(userID)
            let favoriteDicts = try uniqueFavorites.map { try $0.toDictionary() }
            
            try await userDocRef.updateData([
                "favoriteCourts": favoriteDicts
            ])
            
            DispatchQueue.main.async {
                self.favoriteCourts = Array(uniqueFavorites)
                print("Successfully cleaned up \(courtIDs.count - uniqueIDs.count) duplicate favorites")
                self.objectWillChange.send()
            }
        } catch {
            print("Error cleaning up duplicate favorites: \(error.localizedDescription)")
        }
    }

    // Add a new method to force fetch courts regardless of cache status
    func refreshCourts(location: CLLocation) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            print("🔄 Refreshing courts data...")
            self.placesService.fetchNearbyCourts(location: location) { [weak self] newCourts in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.courts = newCourts
                    // After fetching new courts, update their favorite status
                    if let userID = self.currentUserID {
                        self.fetchFavoriteCourts()
                    }
                    self.lastUpdateTime = Date()
                }
            }
        }
    }
} 
