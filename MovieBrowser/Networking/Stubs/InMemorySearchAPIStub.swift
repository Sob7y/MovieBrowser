//
//  InMemorySearchAPIStub.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 17/10/2025.
//

import Foundation

final class InMemorySearchAPIStub: SearchAPIProtocol {
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        // Deterministic, fast results for UITests
        let items = [
            Movie(id: 1, title: "Jack Reacher", overview: "A drifter investigates.",
                  releaseDate: "2012-12-21", posterPath: nil),
            Movie(id: 2, title: "Jack Reacher: Never Go Back", overview: "On the run.",
                  releaseDate: "2016-10-19", posterPath: nil)
        ]
        return MovieSearchResponse(page: 1, results: items, totalPages: 1, totalResults: items.count)
    }
}
