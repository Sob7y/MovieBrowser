//
//  AppConfig.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

enum AppConfig {
    static var tmdbAccessToken: String {
        if let token = Bundle.main.infoDictionary?["TMDB_ACCESS_TOKEN"] as? String, !token.isEmpty {
            return token
        }
        assertionFailure("TMDB_ACCESS_TOKEN is missing. Check xcconfig/Info.plist wiring.")
        return ""
    }
}
