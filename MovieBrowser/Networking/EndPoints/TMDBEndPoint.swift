//
//  TMDBEndPoint.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

enum TMDBEndpoint {
    case searchMovie(query: String, page: Int)

    var url: URL {
        var components = URLComponents(string: "https://api.themoviedb.org")!
        switch self {
        case .searchMovie(query: let query, page: let page):
            components.path = "/3" + "/search/movie"
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        }
        return components.url!
    }
}
