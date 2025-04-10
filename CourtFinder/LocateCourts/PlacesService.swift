//
//  PlacesService.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/28/24.
//

import Foundation
import CoreLocation

class PlacesService {
    // Replace hardcoded API key with a computed property that gets the key from Info.plist
    private var apiKey: String {
        guard let infoPlistPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let infoPlist = NSDictionary(contentsOfFile: infoPlistPath),
              let key = infoPlist.object(forKey: "GMSApiKey") as? String  else {
                fatalError("Couldn't find API key in either Info.plist")
        }
        return key
    }
    
    func fetchNearbyCourts(location: CLLocation, completion: @escaping ([Court]) -> Void) {
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/textsearch/json")
        components?.queryItems = [
            URLQueryItem(name: "query", value: "basketball courts"),
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            print("❌ Invalid URL for text search")
            completion([])
            return
        }
        
        print("🔍 Fetching courts near (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API request failed: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No data received from API")
                completion([])
                return
            }
            
//            // --- ADDED --- Print raw response data as String
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("📄 Raw API Response:\n\(responseString)")
//            } else {
//                print("⚠️ Could not convert API response data to String")
//            }
//            // --- END ADDED ---
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(PlacesResponse.self, from: data)
//                print("✅ Found \(result.results.count) courts")
                
                if result.results.isEmpty {
//                    print("⚠️ No courts found in this area")
                    completion([])
                    return
                }
                
                // Calculate distances and sort results
                var courts = result.results
                for index in courts.indices {
                    courts[index].calculateDistance(from: location)
                }
                
                let sortedCourts = courts.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
                DispatchQueue.main.async {
                    completion(sortedCourts)
                }
            } catch {
                print("❌ Failed to decode API response: \(error)")
                completion([])
            }
        }.resume()
    }
    
    private struct PlacesResponse: Decodable {
        let status: String
        let results: [Court]
        let html_attributions: [String]
        let next_page_token: String?
    }
}
