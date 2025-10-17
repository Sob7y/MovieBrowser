//
//  MovieDateFormatter.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 16/10/2025.
//

import Foundation

enum MovieDateFormatter {
    static let input: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"   // TMDB input
        return f
    }()
    
    static let outputFull: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.timeZone = .autoupdatingCurrent
        f.dateFormat = "MMM d, yyyy"  // "Oct 17, 2025"
        return f
    }()
}
