//
//  MovieModel.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation
import UIKit

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(path)")
    }
}

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    func load(_ url: URL) async throws -> UIImage {
        if let c = cache.object(forKey: url as NSURL) { return c }
        let (data, _) = try await URLSession.shared.data(from: url)
        let image = UIImage(data: data) ?? UIImage()
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}

extension Movie {
    var formattedReleaseDate: String {
        guard let s = releaseDate,
              let date = MovieDateFormatter.input.date(from: s) else { return "—" }
        return MovieDateFormatter.outputFull.string(from: date)
    }
}

// For Favorite Use
extension Movie: Encodable {}
