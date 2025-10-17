//
//  MovieSearchResponse.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

// MARK: - Search response
struct MovieSearchResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}
