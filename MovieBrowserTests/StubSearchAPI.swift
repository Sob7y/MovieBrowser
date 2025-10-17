//
//  StubSearchAPI.swift
//  MovieBrowserTests
//
//  Created by Mohamed Khaled on 16/10/2025.
//

import Foundation
@testable import MovieBrowser

final class StubSearchAPI: SearchAPIProtocol {
    var responses: [Int: MovieSearchResponse] = [:]
    var error: Error?
    
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        if let error = error { throw error }
        if let responses = responses[page] { return responses }
        throw NSError(domain: "StubSearchAPI", code: -1)
    }
}
