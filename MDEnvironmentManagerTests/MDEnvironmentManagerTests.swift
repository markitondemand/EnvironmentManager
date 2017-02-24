//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
import Foundation

@testable import MDEnvironmentManager

class MDEnvironmentManagerTests: XCTestCase {
    // Builders
    func defaultEnvironmentManager() -> EnvironmentManager {
        let en = EnvironmentManager()
        en.add(apiName: "service1", environmentUrls: [("acc", URL(string: "http://acc.api.domain.com")!), ("prod", URL(string: "http://prod.api.domain.com")!)])
        return en
    }
    
    // Tests
    func  testEnvironmentChangingForASingleEntry() {
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
    
    func testNotifications() {
        let expectedOldEnv = "acc"
        let expectedNewEnv = "prod"
        
        let em = EnvironmentManager()
        em.add(apiName: "service1", environmentUrls: [("acc", URL(string: "http://acc.api.domain.com")!), ("prod", URL(string: "http://prod.api.domain.com")!)])
        
        let observer = TestEnvironmentObserver()
        
        // When
        em.select(environment: "prod", forAPI: "service1")
        
        // Then
        XCTAssertEqual(observer.oldEnv, expectedOldEnv)
        XCTAssertEqual(observer.newEnv, expectedNewEnv)
    }
    
    func testGetters() {
        let en = self.defaultEnvironmentManager()
        
        XCTAssertEqual(en.apiNames(), ["service1"])
        en.add(apiName: "a", environmentUrls: [("acc", URL(string: "https://acc.other.api.com")!)])
        
        XCTAssertEqual(en.apiNames(), ["a", "service1"])
    }
    
    
    // helper
    class TestEnvironmentObserver {
        var oldEnv: String!
        var newEnv: String!
        
        init() {
            NotificationCenter.default.addObserver(forName: Notification.Name.EnvironmentDidChange, object: nil, queue: nil) { (notification: Notification) in
                self.oldEnv = notification.userInfo?[EnvironmentChangedKeys.OldEnvironment] as? String ?? ""
                self.newEnv = notification.userInfo?[EnvironmentChangedKeys.NewEnvironment] as? String ?? ""
            }
        }
    }
}

