//
//  TestData.swift
//  MovieBrowserTests
//
//  Created by Mohamed Khaled on 16/10/2025.
//

import Foundation
@testable import MovieBrowser

enum TestData {
    static func movie(
            id: Int = 1,
            title: String = "Test Title",
            overview: String? = nil,
            releaseDate: String? = "2018-08-09",
            posterPath: String? = "/poster.jpg"
    ) -> Movie {
        let resolvedOverview = overview ?? "Overview for \(title)" // compute inside, not as default
        return Movie(
            id: id,
            title: title,
            overview: resolvedOverview,
            releaseDate: releaseDate,
            posterPath: posterPath
        )
    }
    
    static func page(
        number: Int = 1,
        totalPages: Int = 1,
        count: Int = 3
    ) -> MovieSearchResponse {
        let items = (0..<count).map { i in
            movie(id: number * 1000 + i, title: "Movie \(number)-\(i)")
        }
        return MovieSearchResponse(
            page: number,
            results: items,
            totalPages: totalPages,
            totalResults: count * totalPages
        )
    }
}
