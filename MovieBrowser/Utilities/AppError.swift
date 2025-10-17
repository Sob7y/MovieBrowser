//
//  AppError.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 17/10/2025.
//

import Foundation

enum AppError: LocalizedError {
    case offline
    case timeout
    case unauthorized      // invalid/expired token
    case server            // 5xx
    case decoding
    case emptyResults
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .offline:       return "You’re offline. Please check your internet connection."
        case .timeout:       return "The request took too long. Please try again."
        case .unauthorized:  return "Authorization failed. Check your API token."
        case .server:        return "The server is having trouble. Please try again later."
        case .decoding:      return "We couldn’t read the response. Please try again."
        case .emptyResults:  return "No results found."
        case .custom(let m): return m
        }
    }
}

func mapToAppError(_ error: Error, response: HTTPURLResponse?) -> AppError {
    if let urlErr = error as? URLError {
        switch urlErr.code {
        case .notConnectedToInternet, .networkConnectionLost: return .offline
        case .timedOut: return .timeout
        default: break
        }
    }
    if let status = response?.statusCode {
        if status == 401 { return .unauthorized }
        if (500...599).contains(status) { return .server }
        if status == 404 { return .custom("Not found.") }
    }
    if (error as NSError).domain == NSCocoaErrorDomain { return .decoding }
    return .custom(error.localizedDescription)
}
