//
//  SearchFlowTests.swift
//  MovieBrowserUITests
//
//  Created by Mohamed Khaled on 17/10/2025.
//

import Foundation
import XCTest

final class SearchFlowTests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("UITEST_MODE") // enable your mock path (optional)
        app.launch()
    }
    
    
    func testSearchShowsResultsAndOpenDetails() {
        // Search field exists
        let searchField = app.searchFields["search.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3), "Search bar should exist")
        
        // Type a query
        searchField.tap()
        searchField.typeText("jack reacher")
        app.keyboards.buttons["Search"].firstMatch.tap() // if using UISearchBar return key

        // Wait for first cell
        let table = app.tables["search.table"]
        XCTAssertTrue(table.waitForExistence(timeout: 3), "Search table should exist")

        // A cell title should appear
        let firstCellTitle = table.staticTexts["cell.title"].firstMatch
        XCTAssertTrue(firstCellTitle.waitForExistence(timeout: 5), "First result should load")

        // Tap the first cell to open details
        firstCellTitle.tap()
//
        // Verify details screen
        let detailsTitle = app.staticTexts["details.title"]
        XCTAssertTrue(detailsTitle.waitForExistence(timeout: 3), "Details title should be visible")

        let detailsDate = app.staticTexts["details.date"]
        XCTAssertTrue(detailsDate.exists, "Details date should be visible")

        let overview = app.staticTexts["details.overview"]
        XCTAssertTrue(overview.exists, "Overview should be visible")
    }
}
