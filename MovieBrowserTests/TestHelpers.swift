//
//  TestHelpers.swift
//  MovieBrowserTests
//
//  Created by Mohamed Khaled on 16/10/2025.
//

import Foundation
@testable import MovieBrowser

extension Movie {
    static func test(
        id: Int,
        title: String,
        overview: String? = nil,
        releaseDate: String? = "2025-10-17",
        posterPath: String? = "/poster.jpg"
    ) -> Movie {
        let resolvedOverview = overview ?? "Overview for \(title)"
        return Movie(
            id: id,
            title: title,
            overview: resolvedOverview,
            releaseDate: releaseDate,
            posterPath: posterPath
        )
    }
}

extension MovieSearchResponse {
    static func testPage(
        page: Int,
        totalPages: Int,
        count: Int
    ) -> MovieSearchResponse {
        let items = (0..<count).map { i in
            Movie.test(id: page*1000 + i, title: "Movie \(page)-\(i)")
        }
        return MovieSearchResponse(
            page: page,
            results: items,
            totalPages: totalPages,
            totalResults: count * totalPages,
        )
    }
}
