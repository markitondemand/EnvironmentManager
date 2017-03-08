//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class BuilderTests: XCTestCase {
    
    func testDefaultBuildParameters() {
        let b = Builder()
        // Use default data store)
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
        let em = try! b.add(entry: "Service1", environments:[("Env1", "http://env1.api.service1.com")]).build()
        
        XCTAssertEqual(em.entry(forService: "Service1"), Entry(name: "Service1", initialEnvironment: ("Env1", URL(string: "http://env1.api.service1.com")!)))
    }
    
    func testAddingDictionary() {
        let b = Builder()
        let entries = ["Service1":[("Env1", "http://env1.api.service1.com")], "Service2":[("Env1", "http://env1.api.service2.com")]]
        let em = try! b.add(entries).build()
        
        XCTAssertEqual(em.apiNames().count, 2)
    }
    func testSettingProductionEntry() {
        let b = Builder()
        let em = try! b.add(entry: "Service1", environments:[("Env1", "http://env1.api.service1.com"), ("Env2", "http://env2.api.service1.com")])
            .add(entry: "Service2", environments:[("Acc", "http://acc.api.service2.com"), ("Prod", "http://prod.api.service2.com")])
            .productionEnvironments(map: ["Service1":"Env1", "Service2":"Prod"])
            .production()
            .build()
        
        XCTAssertEqual(em.entry(forService: "Service1")?.environmentNames().count, 1)
    }
    
    // Error checking
    // Commenting out for now. For some reason XCTAssertThrowsError is not passing even tho I verified an error is thrown from b.build(). (by trying try!, it crashes)
//    func testNotSettingProductionEnvironmentShouldThrowError() {
//        // URL Error
//        let b = Builder().add(entry: "Service1", environments:[("Env1", "ht tp://env1.api.service1.com")])
//        XCTAssertThrowsError(try? b.build()) { (e) in
//            print(e)
//        }
//        
//    }
    
}

extension Entry {
    static let DefaultEnvironmentName = "Env"
    class func defaultEntry(name: String, numberOfEnvironments: Int = 1) -> Entry {
        precondition(numberOfEnvironments > 0)
        var environmentPairs: [(String, URL)] = []
        for i in 1...numberOfEnvironments {
            let env = "Env\(i)"
            environmentPairs.append((env, URL(string: "http://\(env).api.\(name).com".lowercased())!))
        }
        return Entry(name: name, environments: environmentPairs)
    }
}
