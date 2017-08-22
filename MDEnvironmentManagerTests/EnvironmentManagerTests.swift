//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
import Foundation

@testable import MDEnvironmentManager


class MDEnvironmentManagerTests: XCTestCase {
//    var backingStore: DictionaryStore!
    
    override func setUp() {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    override func tearDown() {
    }
    
    // Builders
    func defaultEnvironmentManager() -> EnvironmentManager {
        let en = EnvironmentManager(backingStore: DictionaryStore())
        return en
    }
    
    // Tests
    
    func testEnvironmentManagerCreatesURL() {
        let path = "the/path/to/resource/"
        let expectedURL1 = URL(string: "ev1.test.com")!.appendingPathComponent(path)
        let expectedURL2 = URL(string: "ev2.test.com")!.appendingPathComponent(path)
        
        let em = defaultEnvironmentManager()
        em.add(entry: generateTestEntry(environmentCount: 2))

        let accURL = em.urlFor(apiName: "Test", path: path)
        
        // test builds from default URL. also tests that default enviromnment is the "first" element in the previous constructor's array parameter
        XCTAssertEqual(accURL, expectedURL1)
        em.select(environment:"EV2", forAPI:"Test")
        let URL2 = em.urlFor(apiName: "Test", path: path)
        
        XCTAssertEqual(URL2, expectedURL2)
        XCTAssertEqual(em.currentEnvironmentFor(apiName: "Test"), "EV2")
        
        XCTAssertNil(em.urlFor(apiName: "unknown-service", path: path))
    }
    
    func testNotifications() {
        let expectedOldEnv = "EV1"
        let expectedNewEnv = "EV2"
        
        let em = defaultEnvironmentManager()
        em.add(entry: generateTestEntry(environmentCount: 2))
        
        let observer = TestEnvironmentNotificationObserver()
        
        // When
        em.select(environment: "EV2", forAPI: "Test")
        
        // Then
        XCTAssertEqual(observer.oldEnv, expectedOldEnv)
        XCTAssertEqual(observer.newEnv, expectedNewEnv)
    }
    
    func testEnvironmentManagerGetters() {
        let en = defaultEnvironmentManager()
        en.add(entry: generateTestEntry("TestOne", environmentCount:2))
        en.add(entry: generateTestEntry("TestTwo"))
        
        // test return service name + default to using ascending sort
        XCTAssertEqual(en.apiNames(), ["TestOne", "TestTwo"])
        
        
        // test return base API
        XCTAssertEqual(en.baseUrl(apiName: "TestOne"), URL(string: "ev1.testone.com")!)
        
        en.select(environment: "EV2", forAPI: "TestOne")
        XCTAssertEqual(en.baseUrl(apiName: "TestOne"), URL(string: "ev2.testone.com")!)
        
        var entry = Entry(name: "Service", initialEnvironment: ("acc", URL(string:"http://acc.api.service.com")!))
        entry.add(url: URL(string:"http://prod.api.service.com")!, forEnvironment: "prod")
        
        XCTAssertEqual(entry.environmentNames(), ["acc", "prod"])
    }

    func testReadWriteData() {
//        let environments = [("acc", defaultAccUrl), ("prod", defaultProdUrl)]
//        let entry = Entry(name: "service1", environments: environments)
//        
//        
//        let en = EnvironmentManager(backingStore:store)
//        en.add(entry: entry)
//        en.select(environment: "prod", forAPI: "service1")
//        
//        
//        let en2 = EnvironmentManager(backingStore: store)
//        en2.add(apiName: "service1", environmentUrls: environments)
//        XCTAssertEqual(en2.currentEnvironmentFor(apiName: "service1"), "prod")
//        XCTFail()
    }
    
    
    
    // MARK: - custom entries
//    func testAddCustomEnvironment() {
//        let store = DictionaryStore()
//        let en = EnvironmentManager(backingStore: store)
//        
//        let entry = Entry(name: "Test", initialEnvironment: ("acc", URL(string: "http://acc.api.service.com")!))
//        en.createCustomEntry(entry)
//        
//        // Then
//        XCTAssertEqual(en.currentEnvironmentFor(apiName: "Test"), "acc")
//
//    }
//    
//    func testCustomEntryStoresToDataStore() {
//        let store = DictionaryStore()
//        let en1 = EnvironmentManager(backingStore: store)
//        
//        en1.createCustomEntry(generateTestEntry())
//        
//        let en2 = EnvironmentManager(backingStore: store)
//        
//        // Then
//        XCTAssertEqual(en2.currentEnvironmentFor(apiName: "TestEntry"), "acc")
//    }
//    
//    func testRemoveCustomEnvironment() {
//        let store = DictionaryStore()
//        let en1 = EnvironmentManager(backingStore: store)
//        
//        en1.createCustomEntry(generateTestEntry())
//        
//        let en2 = EnvironmentManager(backingStore: store)
//        
//        XCTAssertNotNil(en2.entry(forService: "TestEntry"))
//        en2.removeEntry("TestEntry")
//        
//        XCTAssertNil(en2.entry(forService: "TestEntry"))
//    }
    
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

