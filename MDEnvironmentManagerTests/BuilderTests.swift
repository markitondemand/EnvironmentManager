//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class BuilderTests: XCTestCase {
    
    func testDefaultBuildParameters() {
        let b = Builder()
        // Use default data store
//        b.setDataStore(store: <#T##DataStore#>)
        let em = try! b.build()
        
        let store = UserDefaultsStore()
        XCTAssert(type(of:em.store) == type(of:store))
    }
    
    func testSettingStoreParameter() {
        let b = Builder()
        let em = try! b.setDataStore(store: DictionaryStore()).build()

        XCTAssert(type(of:em.store) == type(of:DictionaryStore()))
    }
    
    func testAddingEntry() {
        let b = Builder()
        let em = try! b.add(entry: Entry(name: "Env1", initialEnvironment: ("Acc", URL(string: "http://acc.api.env1.com")!))).build()
        
        XCTAssertEqual(em.entry(forService: "Env1"), Entry(name: "Env1", initialEnvironment: ("Acc", URL(string: "http://acc.api.env1.com")!)))
    }
    
//    func testSettingProductionEntry() {
//    
//    }
    
}
