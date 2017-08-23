//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class CustomEntryTests: XCTestCase {
    var buildTestEntry: Entry {
        return Entry(name: "Test", initialEnvironment: ("acc", URL(string: "http://acc.api.com")!))
    }
    
    func testAddingEntry() {
        let store = DictionaryStore()
        let sut = CustomEntryStore(store)
        
        sut.addCustomEntry(buildTestEntry)
        
        XCTAssertEqual(sut["Test"], buildTestEntry)
    }
    
    func testAddingAnEntryPersistsTheEntryInStore() {
        let store = DictionaryStore()
        let sut = CustomEntryStore(store)

        // When
        sut.addCustomEntry(buildTestEntry)
        
        let new = CustomEntryStore(store)
        XCTAssertEqual(buildTestEntry, new.allEntries[0])
    }
    
    func testRemovingEntryByName() {
        let sut = CustomEntryStore(DictionaryStore())
        sut.addCustomEntry(buildTestEntry)
        
        let result = sut.removeCustomEntry("Test")
        
        XCTAssertTrue(result)
        XCTAssertTrue(sut.allEntries.isEmpty)
    }
    
    func testRemovingEntryByEntry() {
        let sut = CustomEntryStore(DictionaryStore())
        sut.addCustomEntry(buildTestEntry)
        
        let result = sut.removeCustomEntry(buildTestEntry)
        
        XCTAssertTrue(result)
        XCTAssertTrue(sut.allEntries.isEmpty)
    }
    
    func testAddingEnvironmentsToAlreadyExistingEnvironment() {
        // Given
        let sut = CustomEntryStore(DictionaryStore())
        sut.addCustomEntry(buildTestEntry)
        
        // When
        sut.addEnvironments([("prod", URL(string: "http://prod.api.com")!)], forEntry: "Test")
        
        // Then
        XCTAssertEqual(sut["Test"]?.environments.count, 2)
    }
    
    func testAddingEnvironmentsToNonExistingEntry() {
        let sut = CustomEntryStore(DictionaryStore())
        sut.addEnvironments([("acc", URL(string: "http://acc.api.com")!)], forEntry: "Test")
        
        XCTAssertEqual(sut["Test"], buildTestEntry)
    }
}
