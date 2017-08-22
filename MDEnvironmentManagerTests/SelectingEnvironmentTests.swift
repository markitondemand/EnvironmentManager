//
//  SelectingEnvironmentTests.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 8/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class SelectingEnvironmentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testNoPreviouslySelectedEnvironment() {
        let sut = EnvironmentStore()
        let environmentName = sut.currentlySelectedEnvironmentFor(generateTestEntry())
        
        XCTAssertEqual(environmentName, "EV1")
    }
    
    func testNoPreviouslySelectedEnvironmentMultipleEnvironmentsDefaultsToFirst() {
        let sut = EnvironmentStore()
        let environmentName = sut.currentlySelectedEnvironmentFor(generateTestEntry())
        
        XCTAssertEqual(environmentName, "EV1")
    }
    
    func testSelectingEnvironmentForEntrySetsThatEnvironment() {
        let sut = EnvironmentStore()
        
        // When
        sut.selectEnvironment("EV2", for: generateTestEntry(environmentCount: 2))
        let environmentName = sut.currentlySelectedEnvironmentFor(generateTestEntry(environmentCount: 2))
        
        XCTAssertEqual(environmentName, "EV2")
    }
    
    func testSelectingNonExistantEnvironmentForEntryDoesNothing() {
        let sut = EnvironmentStore()
        let testEntry = generateTestEntry(environmentCount:2)
        
        // When
        sut.selectEnvironment("UnknownEnvironment", for: testEntry)
        let environmentName = sut.currentlySelectedEnvironmentFor(testEntry)

        XCTAssertEqual(environmentName, "EV1")
    }
    
    func testSelectingEnvironmentOnMultipleEntries() {
        let sut = EnvironmentStore()
        let testEntry1 = generateTestEntry("API1", environmentCount:2)
        let testEntry2 = generateTestEntry("API2", environmentCount:2)
        
        // When
        sut.selectEnvironment("EV1", for: testEntry1)
        sut.selectEnvironment("EV2", for: testEntry2)
        
        let environmentName = sut.currentlySelectedEnvironmentFor(testEntry1)
        
        XCTAssertEqual(environmentName, "EV1")
    }
    
    func testSelectEnvironmentsRemembersSelectionAcrossEnvironmentStoreInstances() {
        let dataStore = DictionaryStore()
        let store1 = EnvironmentStore(backingStore: dataStore)
        let entry = generateTestEntry(environmentCount:2)
        store1.selectEnvironment("EV2", for: entry)
        
        // When
        let store2 = EnvironmentStore(backingStore: dataStore)
        
        XCTAssertEqual(store2.currentlySelectedEnvironmentFor(entry), "EV2")
    }
    
    func testBuildURLForCurrentEnvironment() {
        let sut = EnvironmentStore()
        sut.selectEnvironment("EV3", for: generateTestEntry(environmentCount: 3))
        
        // When
        let url = sut.buildUrl(for: generateTestEntry(environmentCount: 3), path: "path/to/resource")
        
        // Then
        XCTAssertEqual(url, URL(string: "ev3.test.com/path/to/resource")!)
    }
    
//    func testSelectingEnvironmentBroadcastsNotification() {
//        XCTFail()
//    }
}

