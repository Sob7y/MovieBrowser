//
//  MovieDetailsViewModel.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

@MainActor
final class MovieDetailsViewModel {
    // MARK: - Outputs
    private(set) var titleText: String = "" {
        didSet { onDetailsChanged?() }
    }
    private(set) var releaseDateText: String = "" {
        didSet { onDetailsChanged?() }
    }
    private(set) var overviewText: String = "" {
        didSet { onDetailsChanged?() }
    }
    private(set) var posterURL: URL? {
        didSet { onDetailsChanged?() }
    }
    
    var onDetailsChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private var movie: Movie
    
    // MARK: - Init
    init(movie: Movie) {
        self.movie = movie
        // self.repository = repository
        apply(movie)
    }
    
    func setMovie(_ newMovie: Movie) {
        self.movie = newMovie
        apply(newMovie)
    }
    
    private func apply(_ movie: Movie) {
        titleText = movie.title
        releaseDateText = movie.formattedReleaseDate
        overviewText = (movie.overview?.isEmpty == false) ? movie.overview! : "No overview available."
        posterURL = movie.posterURL
    }
}
