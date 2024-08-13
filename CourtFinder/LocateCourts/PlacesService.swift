//
//  PlacesService.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/28/24.
//

import Foundation
import CoreLocation

class PlacesService {
    private let apiKey = "AIzaSyCKA1J7CfpB49BYhIpCiiWWJTrDOe_B95E"
    
    func fetchNearbyCourts(location: CLLocation, completion: @escaping ([Court]) -> Void) {
            let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=2000&type=park&keyword=basketball&key=\(apiKey)"
            
            guard let url = URL(string: urlString) else { return }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }

                do {
                    var result = try JSONDecoder().decode(PlacesResponse.self, from: data)
                    for index in result.results.indices {
                        result.results[index].calculateDistance(from: location)
                    }
                    completion(result.results)
                } catch {
                    print("Error decoding: \(error)")
                    completion([])
                }
            }.resume()
        }
    }

    struct PlacesResponse: Decodable {
        var results: [Court]
    }

    struct Court: Decodable, Identifiable {
        var id = UUID()
        let name: String
        let vicinity: String
        let geometry: Geometry

        var distance: Double?

        struct Geometry: Decodable {
            let location: Location

            struct Location: Decodable {
                let lat: Double
                let lng: Double
            }
        }

        enum CodingKeys: String, CodingKey {
            case name
            case vicinity
            case geometry
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            vicinity = try container.decode(String.self, forKey: .vicinity)
            geometry = try container.decode(Geometry.self, forKey: .geometry)
        }

        mutating func calculateDistance(from location: CLLocation) {
            let courtLocation = CLLocation(latitude: geometry.location.lat, longitude: geometry.location.lng)
            distance = location.distance(from: courtLocation) / 1609.34 // distance in miles
        }
    }
