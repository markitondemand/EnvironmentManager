//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
import Foundation

@testable import MDEnvironmentManager

class MDEnvironmentManagerTests: XCTestCase {
    func testEnvironmentChangingForASingleEntry() {
        let path = "the/path/to/resource/"
        let expectedProdURL = URL(string: "http://prod.api.domain.com/the/path/to/resource/")!
        let expectedAccURL = URL(string: "http://acc.api.domain.com/the/path/to/resource/")!
        
        var entry = Entry(name: "service1", initialEnvironment: ("prod", URL(string: "http://prod.api.domain.com")!))
        
        let prodURL = entry.buildURLWith(path: path)
        
        XCTAssertEqual(prodURL, expectedProdURL)
        entry.add(url: URL(string: "http://acc.api.domain.com")!, forEnvironment: "acc")
        
        let prodURLTwo = entry.buildURLWith(path: path)
        
        // test current environment stays after adding another environment
        XCTAssertEqual(prodURLTwo, expectedProdURL)
        
        entry.currentEnvironment = "acc"
        let accURL = entry.buildURLWith(path: path)
        XCTAssertEqual(accURL, expectedAccURL)
        
        // test that environment only changes if it is exists
        entry.currentEnvironment = "unknown-environment"
        XCTAssertEqual(entry.currentEnvironment, "acc")
    }
    
    func testEnvironmentManagerCreatesURL() {
        let path = "the/path/to/resource/"
        let expectedProdURL = URL(string: "http://prod.api.domain.com/the/path/to/resource/")!
        let expectedAccURL = URL(string: "http://acc.api.domain.com/the/path/to/resource/")!
        
        let em = EnvironmentManager()
        em.add(apiName: "service1", environmentUrls: [("acc", URL(string: "http://acc.api.domain.com")!), ("prod", URL(string: "http://prod.api.domain.com")!)])

        let accURL = em.urlFor(apiName: "service1", path: path)
        
        // test builds from default URL. also tests that default enviromnment is the "first" element in the previous constructor's array parameter
        XCTAssertEqual(accURL, expectedAccURL)
        em.select(environment:"prod", forAPI:"service1")
        let prodURL = em.urlFor(apiName: "service1", path: path)
        
        XCTAssertEqual(prodURL, expectedProdURL)
        XCTAssertEqual(em.currentEnvironmentFor(apiName: "service1"), "prod")
        
        XCTAssertNil(em.urlFor(apiName: "unknown-service", path: path))
    }
    
    
    class TestEnvironmentObserver {
        
    }
}

