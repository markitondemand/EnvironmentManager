//
//  EntryTests.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 3/15/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class EntryTests: XCTestCase {
    let defaultAccUrl = URL(string: "http://acc.api.domain.com")!
    let defaultProdUrl = URL(string: "http://prod.api.domain.com")!
    
    func  testEnvironmentChangingForAnEntry() {
        let path = "the/path/to/resource/"
        let expectedProdURL = URL(string: "http://prod.api.domain.com/the/path/to/resource/")!
        let expectedAccURL = URL(string: "http://acc.api.domain.com/the/path/to/resource/")!
        
        let entry = Entry(name: "service1", initialEnvironment: ("prod", defaultProdUrl))
        
        let prodURL = entry.buildURLWith(path: path)
        
        XCTAssertEqual(prodURL, expectedProdURL)
        entry.add(url: defaultAccUrl, forEnvironment: "acc")
        
        let prodURLTwo = entry.buildURLWith(path: path)
        
        // test current environment stays after adding another environment
        XCTAssertEqual(prodURLTwo, expectedProdURL)
        
        entry.currentEnvironment = "acc"
        let accURL = entry.buildURLWith(path: path)
        XCTAssertEqual(accURL, expectedAccURL)
        
        // test that environment only changes if it is exists
        entry.currentEnvironment = "unknown-environment"
        XCTAssertEqual(entry.currentEnvironment, "acc")
        
        entry.select(environment: "prod")
        XCTAssertEqual(entry.currentEnvironment, "prod")
    }
    
    func testEntryGetters() {
        let entry = Entry(name: "service", initialEnvironment: ("prod", defaultProdUrl))
        entry.add(url: defaultAccUrl, forEnvironment: "acc")
        
        XCTAssertEqual(entry.environment(forIndex: 0), "prod")
        
        XCTAssertEqual(entry.baseUrl(forIndex: 0), defaultProdUrl)
        XCTAssertEqual(entry.baseUrl(forIndex: 1), defaultAccUrl)
    }
    
    func testEntryEquatable() {
        let entry1 = Entry(name: "Service1", initialEnvironment: ("acc", self.defaultAccUrl))
        let entry2 = Entry(name: "Service1", initialEnvironment: ("acc", self.defaultAccUrl))
        
        XCTAssertEqual(entry1, entry2)
        entry2.add(pair: ("prod", self.defaultProdUrl))
        XCTAssertNotEqual(entry1, entry2)
    }
}
