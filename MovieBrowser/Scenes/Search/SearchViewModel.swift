//
//  SearchViewModel.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

@MainActor
final class SearchViewModel {
    private(set) var movies: [Movie] = [] {
        didSet { onMoviesChanged?(movies) }
    }
    
    var onMoviesChanged: (([Movie]) -> Void)?
    var onError: ((AppError) -> Void)?
    
    private var currentQuery: String = ""
    private var currentPage = 0
    private var totalPages = 1
    private var isLoading = false
    var hasMore: Bool { currentPage < totalPages }
    var isBusy: Bool { isLoading }
    
    private var favoriteIDs: Set<Int> = []
    var onFavoritesChanged: (() -> Void)?
    
    // Dependencies
    private let api: SearchAPIProtocol
    init(api: SearchAPIProtocol) {
        self.api = api
        self.favoriteIDs = Set(FavoritesStore.shared.all().map { $0.id })
    }
    
    // Call from viewDidLoad to show something immediately (cached last search),
    // then tries to refresh page 1 from network.
    func loadInitialContent() {
        if let last = UserDefaults.standard.string(forKey: Constants.Keys.lastQuery),
           !last.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Show cached instantly if available
            if let data = SimpleCache.loadFirstPage(query: last),
               let cached = try? JSONDecoder.makeSnakeCaseDecoder.decode(MovieSearchResponse.self, from: data) {
                currentQuery = last
                currentPage = cached.page
                totalPages  = cached.totalPages
                movies      = cached.results
            } else {
                // No cache found
                currentQuery = last
                self.emptyPagingState()
            }
            
            Task { await loadNextPageIfNeeded(force: true) }
        }
    }
    
    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        currentQuery = trimmed
        self.emptyPagingState()
        guard !trimmed.isEmpty else { return }
        
        Task { await loadNextPageIfNeeded(force: true) }
    }
    
    // Load more when nearing bottom
    
    func loadNextPageIfNeeded(force: Bool = false) async {
        guard !isLoading else { return }
        guard !currentQuery.isEmpty else { return }
        
        // Decide the next page explicitly
        let nextPage = (currentPage == 0) ? 1 : currentPage + 1
        
        // Stop if we’re at the end
        if !force, currentPage >= totalPages, currentPage != 0 { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.searchMovies(query: currentQuery, page: nextPage)
            
            if nextPage == 1 {
                let normalized = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                UserDefaults.standard.setValue(normalized, forKey: Constants.Keys.lastQuery)
            }
            // Update paging state
            currentPage = response.page
            totalPages = response.totalPages
            // Replace on page 1, append on subsequent pages
            movies = (nextPage == 1) ? response.results : (movies + response.results)
            if movies.isEmpty {
                onError?(.emptyResults)
            }
        } catch let error {
            // Offline / network error fallback
            if nextPage == 1, // only for first page
               let data = SimpleCache.loadFirstPage(query: currentQuery),
               let cached = try? JSONDecoder.makeSnakeCaseDecoder.decode(MovieSearchResponse.self, from: data) {
                currentPage = cached.page
                totalPages = cached.totalPages
                movies = cached.results
                onError?(mapToAppError(error, response: nil))
            } else {
                onError?(.offline)
            }
        }
    }
    
    // Empty paging state
    private func emptyPagingState() {
        currentPage = 0
        totalPages = 1
        movies = []
    }
}

// MARK: Favorites

extension SearchViewModel {
    func isFavorite(_ movie: Movie) -> Bool { favoriteIDs.contains(movie.id) }
    
    func toggleFavorite(_ movie: Movie) {
        if favoriteIDs.contains(movie.id) {
            FavoritesStore.shared.remove(id: movie.id)
            favoriteIDs.remove(movie.id)
        } else {
            FavoritesStore.shared.add(movie)
            favoriteIDs.insert(movie.id)
        }
        onFavoritesChanged?()
        onMoviesChanged?(movies)
    }
}
