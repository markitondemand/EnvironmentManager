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
    
    func testSettingProductionEntryDefaultsToProduction() {
        let b = Builder()
        let em = try! b
            .add(entry: "Service1", environments:[("Env1", "http://env1.api.service1.com"), ("Env2", "http://env2.api.service1.com")])
            .add(entry: "Service2", environments:[("Acc", "http://acc.api.service2.com"), ("Prod", "http://prod.api.service2.com")])
            .productionEnvironments(map: ["Service1":"Env1", "Service2":"Prod"])
            .production()
            .build()
        
        XCTAssertEqual(em.entry(forService: "Service1")?.environmentNames().count, 1)
    }
    
    func testSettingProductionEntryToFalseDoesNotUseProduction() {
        let b = Builder()
        let em = try! b
            .add(entry: "Service1", environments:[("Env1", "http://env1.api.service1.com"), ("Env2", "http://env2.api.service1.com")])
            .add(entry: "Service2", environments:[("Acc", "http://acc.api.service2.com"), ("Prod", "http://prod.api.service2.com")])
            .productionEnvironments(map: ["Service1":"Env1", "Service2":"Prod"])
            .production(expression: { return false })
            .build()
        
        XCTAssertEqual(em.entry(forService: "Service1")?.environmentNames().count, 2)
    }
    
    func testDefaultSortOrderIsOrderOfItemsAdded() {
        // Default is order added
        let b = Builder()
        
        let em = try! b
            .add(entry: "ZService", environments:[("BEnv", "http://benv.api.zervice.com"), ("AEnv", "http://aenv.api.zservice.com")])
            .add(entry: "AService", environments:[("BEnv", "http://benv.api.aservice.com"), ("AEnv", "http://aenv.api.aservice.com")])
            .build()
        
        XCTAssertEqual(em.entry(forIndex: 0)?.name, "ZService")
        XCTAssertEqual(em.entry(forIndex: 0)?.environment(forIndex: 0), "BEnv")
    }
    

}


// MARK: - Error Tests
extension BuilderTests {
    // Error checking
    // Commenting out for now. For some reason XCTAssertThrowsError is not passing even tho I verified an error is thrown from b.build(). (by trying try!, it crashes)
    func testInvalidURLThrowsError() {
        // URL Error
        let b = Builder().add(entry: "Service1", environments:[("Env1", "ht tp://env1.api.service1.com")])
        XCTAssertThrowsError(try b.build()) { (e) in
            guard let error = e as? Builder.BuildError else {
                XCTFail()
                return
            }
            switch error {
            case .UnableToConstructBaseUrl(let service, let urlString):
                XCTAssertEqual(service, "Service1")
                XCTAssertEqual(urlString, "ht tp://env1.api.service1.com")
            default:
                XCTFail()
            }
        }
    }
    
    func testBuilderEnabledForProductionRequiresFullMapping() {
        let b = Builder().add(entry: "Service1", environments:[("Env1", "http://env1.api.service1.com")])
        .production()
        XCTAssertThrowsError(try b.build()) { (e) in
            guard let error = e as? Builder.BuildError else {
                XCTFail()
                return
            }
            switch error {
            case .NoProductionEnvironmentSet(let service):
                XCTAssertEqual(service, "Service1")
            default:
                XCTFail()
            }
        }
    }
    
    func testBuilderEnabledForProductionRequiresValidMapping() {
        let b = Builder().add(entry: "Service1", environments:[("Env1", "http://env1.api.service1.com")])
            .productionEnvironments(map: ["Service1":"Env2"])
            .production()
        XCTAssertThrowsError(try b.build()) { (e) in
            guard let error = e as? Builder.BuildError else {
                XCTFail()
                return
            }
            switch error {
            case .EnvironmentCouldNotBeFound(let service, let name):
                XCTAssertEqual(service, "Service1")
                XCTAssertEqual(name, "Env2")
            default:
                XCTFail()
            }
        }
    }
}
