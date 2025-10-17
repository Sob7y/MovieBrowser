//
//  FavoritesStore.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 16/10/2025.
//

import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()
    private let key = Constants.Keys.favoriteMovies
    private var favorites: [Int: Movie] = [:]   // id → Movie
    private let queue = DispatchQueue(label: "favorites.store", qos: .userInitiated)

    private init() { load() }

    func isFavorite(id: Int) -> Bool { favorites[id] != nil }

    func add(_ movie: Movie) {
        queue.sync {
            favorites[movie.id] = movie
            save()
        }
    }

    func remove(id: Int) {
        queue.sync {
            favorites.removeValue(forKey: id)
            save()
        }
    }

    func all() -> [Movie] {
        queue.sync { Array(favorites.values) }
    }

    // MARK: - Persistence
    private func save() {
        let array = Array(favorites.values)
        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let array = try? JSONDecoder().decode([Movie].self, from: data) else { return }
        favorites = Dictionary(uniqueKeysWithValues: array.map { ($0.id, $0) })
    }
}
