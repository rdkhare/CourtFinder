import Foundation
import CoreLocation

struct Court: Decodable, Encodable, Identifiable {
    var id = UUID()
    let name: String
    let formatted_address: String
    let geometry: Geometry
    let place_id: String
    let types: [String]
    let business_status: String?
    let rating: Double?
    let user_ratings_total: Int?
    var distance: Double?
    let opening_hours: OpeningHours?
    var isFavorite: Bool = false
    
    struct Geometry: Decodable, Encodable {
        let location: Location
        let viewport: Viewport
        
        struct Location: Decodable, Encodable {
            let lat: Double
            let lng: Double
        }
        
        struct Viewport: Decodable, Encodable {
            let northeast: Location
            let southwest: Location
        }
    }
    
    struct OpeningHours: Decodable, Encodable {
        let open_now: Bool?
    }

    enum CodingKeys: String, CodingKey {
        case name
        case formatted_address
        case geometry
        case place_id
        case types
        case business_status
        case rating
        case user_ratings_total
        case opening_hours
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        formatted_address = try container.decode(String.self, forKey: .formatted_address)
        geometry = try container.decode(Geometry.self, forKey: .geometry)
        place_id = try container.decode(String.self, forKey: .place_id)
        types = try container.decode([String].self, forKey: .types)
        business_status = try container.decodeIfPresent(String.self, forKey: .business_status)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        user_ratings_total = try container.decodeIfPresent(Int.self, forKey: .user_ratings_total)
        opening_hours = try container.decodeIfPresent(OpeningHours.self, forKey: .opening_hours)
    }

    mutating func calculateDistance(from location: CLLocation) {
        let courtLocation = CLLocation(latitude: geometry.location.lat, longitude: geometry.location.lng)
        distance = location.distance(from: courtLocation) / 1609.34 // Convert meters to miles
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(formatted_address, forKey: .formatted_address)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(place_id, forKey: .place_id)
        try container.encode(types, forKey: .types)
        try container.encode(business_status, forKey: .business_status)
        try container.encode(rating, forKey: .rating)
        try container.encode(user_ratings_total, forKey: .user_ratings_total)
        try container.encode(opening_hours, forKey: .opening_hours)
    }
}

// Make Court conform to Hashable
extension Court: Hashable {
    static func == (lhs: Court, rhs: Court) -> Bool {
        return lhs.place_id == rhs.place_id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(place_id)
    }
}

extension Court {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return dictionary as? [String: Any] ?? [:]
    }
} 
