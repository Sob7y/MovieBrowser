//
//  SearchAPI.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

protocol SearchAPIProtocol {
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse
}

final class SearchAPI: SearchAPIProtocol {
    
    private let networkClient: NetworkClient
    private let accessToken: String
    
    init(networkClient: NetworkClient = URLSession.shared, accessToken: String) {
        self.networkClient = networkClient
        self.accessToken = accessToken
        configureCache()
    }
    
    private func configureCache() {
        let cache = URLCache(memoryCapacity: 50 * 1024 * 1024,
                             diskCapacity: 200 * 1024 * 1024,
                             diskPath: "tmdb-cache")
        URLCache.shared = cache
    }
    
    private func makeRequest(for endpoint: TMDBEndpoint,
                             cachePolicy: NSURLRequest.CachePolicy = .returnCacheDataElseLoad) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = cachePolicy
        print("accessToken = \("Bearer \(accessToken)")")
        print("url = \(endpoint.url)")
        return request
    }
    
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        let searchMoviesEndpoint: TMDBEndpoint = .searchMovie(query: query, page: page)
        let urlRequestForSearchMovies = makeRequest(for: searchMoviesEndpoint)
        
        do {
            let (responseData, urlResponse) = try await networkClient.data(for: urlRequestForSearchMovies)
            try Self.throwIfBadStatus(urlResponse)
        
            if page == 1 {
                SimpleCache.saveFirstPage(query: query, data: responseData)
                #if DEBUG
                if let url = SimpleCache.fileURLForDebug(query: query) {
                    print("Saved first page cache at:", url.path)
                }
                #endif
            }
            return try Self.decode(responseData)
        } catch {
            if let cached = URLCache.shared.cachedResponse(for: urlRequestForSearchMovies) {
                return try Self.decode(cached.data)
            }
            throw error
        }
    }
    
    private static func throwIfBadStatus(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.custom("No HTTP response.")
        }
        guard (200...299).contains(http.statusCode) else {
            // Pass the HTTPURLResponse so mapToAppError can classify (401/404/5xx/429…)
            throw mapToAppError(URLError(.badServerResponse), response: http)
        }
    }
    
    private static func decode<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
