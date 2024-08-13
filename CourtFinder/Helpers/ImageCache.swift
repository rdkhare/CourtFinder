//
//  ImageCache.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()

    private var cache: URLCache

    private init() {
        let memoryCapacity = 500 * 1024 * 1024 // 500 MB
        let diskCapacity = 500 * 1024 * 1024 // 500 MB
        self.cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "imageCache")
    }

    func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            completion(image)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response, error == nil else {
                completion(nil)
                return
            }

            let cachedData = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedData, for: request)

            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
