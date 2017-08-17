//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
import Foundation

@testable import MDEnvironmentManager


class MDEnvironmentManagerTests: XCTestCase {
    let defaultAccUrl = URL(string: "http://acc.api.domain.com")!
    let defaultProdUrl = URL(string: "http://prod.api.domain.com")!
    
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
        en.add(apiName: "service1", environmentUrls: [("acc", defaultAccUrl), ("prod", defaultProdUrl)])
        return en
    }
    
    // Tests
    
    func testEnvironmentManagerCreatesURL() {
        let path = "the/path/to/resource/"
        let expectedProdURL = defaultProdUrl.appendingPathComponent(path)
        let expectedAccURL = defaultAccUrl.appendingPathComponent(path)
        
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
        
        let observer = TestEnvironmentNotificationObserver()
        
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
        en.add(apiName: "a", environmentUrls: [("acc", defaultAccUrl)])
        XCTAssertEqual(en.apiNames(), ["service1", "a"])
        
        // test return base API
        XCTAssertEqual(en.baseUrl(apiName: "service1"), defaultAccUrl)
        
        en.select(environment: "prod", forAPI: "service1")
        XCTAssertEqual(en.baseUrl(apiName: "service1"), defaultProdUrl)
        
        let entry = Entry(name: "Service", initialEnvironment: ("acc", URL(string:"http://acc.api.service.com")!))
        entry.add(url: URL(string:"http://prod.api.service.com")!, forEnvironment: "prod")
        
        XCTAssertEqual(entry.environmentNames(), ["acc", "prod"])
    }

    func testReadWriteData() {
        let environments = [("acc", defaultAccUrl), ("prod", defaultProdUrl)]
        let entry = Entry(name: "service1", environments: environments)
        
        let store = DictionaryStore()
        let en = EnvironmentManager(backingStore:store)
        en.add(entry: entry)
        en.select(environment: "prod", forAPI: "service1")
        en.save()
        
        
        let en2 = EnvironmentManager(backingStore: store)
        en2.add(apiName: "service1", environmentUrls: environments)
        XCTAssertEqual(en2.currentEnvironmentFor(apiName: "service1"), "prod")
    }
    
    func testAddCustomEnvironment() {
        let store = DictionaryStore()
        let en = EnvironmentManager(backingStore: store)
        
        let entry = Entry(name: "Test", initialEnvironment: ("acc", URL(string: "http://acc.api.service.com")!))
        en.createCustomEntry(entry)
        
        // Then
        XCTAssertEqual(en.currentEnvironmentFor(apiName: "Test"), "acc")
        
    }
    
    func testRemoveCustomEnvironment() {
        XCTFail()
    }
    
//    func testOnlyAllowOne
    
    // helper
    class TestEnvironmentNotificationObserver {
        var oldEnv: String!
        var newEnv: String!
        var callBackBlock: ((TestEnvironmentNotificationObserver) -> Void)?
        
        init() {
            NotificationCenter.default.addObserver(forName: Notification.Name.EnvironmentDidChange, object: nil, queue: nil) { (notification: Notification) in
                self.oldEnv = notification.userInfo?[EnvironmentChangedKeys.OldEnvironment] as? String ?? ""
                self.newEnv = notification.userInfo?[EnvironmentChangedKeys.NewEnvironment] as? String ?? ""
                self.callBackBlock?(self)
            }
        }
        
        
    }
}

