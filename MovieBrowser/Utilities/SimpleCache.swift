//
//  SimpleCache.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

enum SimpleCache {
    private static var dir: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("search-cache", isDirectory: true)
    }

    private static func ensureDir() {
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    private static func file(for query: String) -> URL {
        let key = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "_", options: .regularExpression)
        return dir.appendingPathComponent("search_\(key)_p1.json")
    }

    static func saveFirstPage(query: String, data: Data) {
        ensureDir()
        try? data.write(to: file(for: query), options: .atomic)
    }

    static func loadFirstPage(query: String) -> Data? {
        try? Data(contentsOf: file(for: query))
    }

    #if DEBUG
    static func fileURLForDebug(query: String) -> URL? {
        ensureDir(); return file(for: query)
    }
    #endif
}
