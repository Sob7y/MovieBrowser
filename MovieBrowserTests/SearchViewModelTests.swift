//
//  SearchViewModelTests.swift
//  MovieBrowserTests
//
//  Created by Mohamed Khaled on 16/10/2025.
//

import Foundation
import XCTest
@testable import MovieBrowser

@MainActor
final class SearchViewModelTests: XCTestCase {

    func testInitialSearchLoadsPage1() async {
        let stub = StubSearchAPI()
        stub.responses[1] = .testPage(page: 1, totalPages: 3, count: 2)

        let vm = SearchViewModel(api: stub)
        var movies: [Movie] = []
        vm.onMoviesChanged = { movies = $0 }

        vm.search(query: "The Meg")
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(movies.count, 2)
        XCTAssertTrue(vm.hasMore)
    }

    func testLoadNextPageAppends() async {
        let stub = StubSearchAPI()
        stub.responses[1] = .testPage(page: 1, totalPages: 3, count: 2)
        stub.responses[2] = .testPage(page: 2, totalPages: 3, count: 2)

        let vm = SearchViewModel(api: stub)
        var movies: [Movie] = []
        vm.onMoviesChanged = { movies = $0 }

        vm.search(query: "The Meg")
        try? await Task.sleep(nanoseconds: 150_000_000)

        await vm.loadNextPageIfNeeded()
        try? await Task.sleep(nanoseconds: 150_000_000)

        XCTAssertEqual(movies.count, 4)
    }
}
