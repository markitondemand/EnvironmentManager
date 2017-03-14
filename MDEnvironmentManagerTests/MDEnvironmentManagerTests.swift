//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
import Foundation

@testable import MDEnvironmentManager


class MDEnvironmentManagerTests: XCTestCase {
    let defaultAccURL = URL(string: "http://acc.api.domain.com")!
    let defaultProdURL = URL(string: "http://prod.api.domain.com")!
    
    var backingStore: DictionaryStore!
    
    override func setUp() {
        backingStore = DictionaryStore()
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    // Builders
    func defaultEnvironmentManager() -> EnvironmentManager {
        let en = EnvironmentManager(backingStore: self.backingStore)
        en.add(apiName: "service1", environmentUrls: [("acc", defaultAccURL), ("prod", defaultProdURL)])
        return en
    }
    
    // Tests
    func  testEnvironmentChangingForAnEntry() {
        let path = "the/path/to/resource/"
        let expectedProdURL = URL(string: "http://prod.api.domain.com/the/path/to/resource/")!
        let expectedAccURL = URL(string: "http://acc.api.domain.com/the/path/to/resource/")!
        
        let entry = Entry(name: "service1", initialEnvironment: ("prod", defaultProdURL))
        
        let prodURL = entry.buildURLWith(path: path)
        
        XCTAssertEqual(prodURL, expectedProdURL)
        entry.add(url: defaultAccURL, forEnvironment: "acc")
        
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
        let entry = Entry(name: "service", initialEnvironment: ("prod", defaultProdURL))
        entry.add(url: defaultAccURL, forEnvironment: "acc")
        
        XCTAssertEqual(entry.environment(forIndex: 0), "prod")
        
        XCTAssertEqual(entry.baseUrl(forIndex: 1), defaultAccURL)
        XCTAssertEqual(entry.baseUrl(forIndex: 0), defaultProdURL)
    }
    
    func testEnvironmentManagerCreatesURL() {
        let path = "the/path/to/resource/"
        let expectedProdURL = defaultProdURL.appendingPathComponent(path)
        let expectedAccURL = defaultAccURL.appendingPathComponent(path)
        
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
    
    func testEnvironmentManagerGetters() {
        let en = self.defaultEnvironmentManager()
        
        // test return service name + default to using ascending sort
        XCTAssertEqual(en.apiNames(), ["service1"])
        en.add(apiName: "a", environmentUrls: [("acc", URL(string: "https://acc.api.other.com")!)])
        XCTAssertEqual(en.apiNames(), ["service1", "a"])
        
        // test return base API
        XCTAssertEqual(en.baseUrl(apiName: "service1"), URL(string: "http://acc.api.domain.com")!)
        
        en.select(environment: "prod", forAPI: "service1")
        XCTAssertEqual(en.baseUrl(apiName: "service1"), URL(string: "http://prod.api.domain.com")!)
        
        let entry = Entry(name: "Service", initialEnvironment: ("acc", URL(string:"http://acc.api.service.com")!))
        entry.add(url: URL(string:"http://prod.api.service.com")!, forEnvironment: "prod")
        
        XCTAssertEqual(entry.environmentNames(), ["acc", "prod"])
    }

    func testReadWriteData() {
        let environments = [("acc", defaultAccURL), ("prod", defaultProdURL)]
        let entry = Entry(name: "service1", environments: environments)
        
        let en = EnvironmentManager()
        en.add(entry: entry)
        en.select(environment: "prod", forAPI: "service1")
        
        let store = DictionaryStore()
        en.save(usingStore: store)
        
        
        let en2 = EnvironmentManager(backingStore: store)
        en2.add(apiName: "service1", environmentUrls: environments)
        XCTAssertEqual(en2.currentEnvironmentFor(apiName: "service1"), "prod")
    }
    
    func testEntryEquatable() {
        let entry1 = Entry(name: "Service1", initialEnvironment: ("acc", self.defaultAccURL))
        let entry2 = Entry(name: "Service1", initialEnvironment: ("acc", self.defaultAccURL))
        
        XCTAssertEqual(entry1, entry2)
        entry2.add(pair: ("prod", self.defaultProdURL))
        XCTAssertNotEqual(entry1, entry2)
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

