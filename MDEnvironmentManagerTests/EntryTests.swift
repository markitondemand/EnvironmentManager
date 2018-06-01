//
//  EntryTests.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 3/15/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

// test environments
extension Environment {
    static let acc = "acc"
}

class EntryTests: XCTestCase {
    let defaultAccUrl = URL(string: "http://acc.api.domain.com")!
    let defaultProdUrl = URL(string: "http://prod.api.domain.com")!
    
    var testEntry: Entry { return Entry(name: "Service", initialEnvironment: ("acc", defaultAccUrl)) }
    
    func entryWithName(_ name: Environment, initialEnvironment: (String, URL)) -> Entry {
        return Entry(name: name, initialEnvironment: initialEnvironment)
    }
    
    func testEntryGetters() {
        var entry = entryWithName("service", initialEnvironment: ("prod", defaultProdUrl))
        entry.add(url: defaultAccUrl, forEnvironment: "acc")
        
        XCTAssertEqual(entry.environment(forIndex: 0), "prod")
        
        XCTAssertEqual(entry.baseUrl(forIndex: 0), defaultProdUrl)
        XCTAssertEqual(entry.baseUrl(forIndex: 1), defaultAccUrl)
    }
    
    func testEntryEquatable() {
        let entry1 = entryWithName("Service1", initialEnvironment: ("acc", self.defaultAccUrl))
        var entry2 = entryWithName("Service1", initialEnvironment: ("acc", self.defaultAccUrl))
        
        XCTAssertEqual(entry1, entry2)
        entry2.add(("prod", self.defaultProdUrl))
        XCTAssertNotEqual(entry1, entry2)
    }
    
    // MARK: - Create CSV Tests
    func testWritesToCSVRow() {
        let csv = testEntry.asCSV
        XCTAssertEqual(csv, "Service|acc|http://acc.api.domain.com")
    }
    
    func testMultipleEnvironemntsToCSV() {
        var entry = testEntry
        entry.add(Entry.Pair("prod", defaultProdUrl))
        
        // When
        let csv = entry.asCSV
        
        XCTAssertEqual(csv, "Service|acc|http://acc.api.domain.com\nService|prod|http://prod.api.domain.com")
    }
    
    func testCreatesFromCSVRow() {
        
        let csvRow = "Service|acc|http://acc.api.domain.com"
        
        // When
        let entry = Entry(csv: csvRow)
        
        XCTAssertEqual(entry, testEntry)
        
    }
    
    func testCreateMultipleEnvironments() {
        // Given
        let csvRows = "Service|acc|http://acc.api.domain.com\nService|prod|http://prod.api.domain.com"
        // When
        let entry = Entry(csv: csvRows)!
        
        XCTAssertEqual(entry.environmentNames(), ["acc", "prod"])
    }
    
    func testCreateMultipleEnvironmentsWithDifferingNamesFails() {
        // Given
        let csvRows = "Service|acc|http://acc.api.domain.com\nOtherService|prod|http://prod.api.domain.com"
        
        // When
        let entry = Entry(csv: csvRows)
        
        // Then
        XCTAssertNil(entry)
    }

}
