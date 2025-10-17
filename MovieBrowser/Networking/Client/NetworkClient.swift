//
//  NetworkClient.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation

protocol NetworkClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkClient {}
