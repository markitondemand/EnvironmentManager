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
        let em = try! b.setStoreType(.inMemory).build()

        XCTAssert(type(of:em.store) == type(of:DictionaryStore()))
    }
    
    func testAddingEntry() {
        let b = Builder()
        let em = try! b.add(entry: "Service1", environments:[(.env1, "http://env1.api.service1.com")]).build()
        
        XCTAssertEqual(em.entry(for: "Service1"), Entry(name: "Service1", initialEnvironment: (.env1, URL(string: "http://env1.api.service1.com")!)))
    }
    
    func testSettingProductionEntryDefaultsToProduction() {
        let b = Builder().setStoreType(.inMemory)
        let em = try! b
            .add(entry: "Service1", environments:[(.env1, "http://env1.api.service1.com"), (.env2, "http://env2.api.service1.com")])
            .add(entry: "Service2", environments:[(.acc, "http://acc.api.service2.com"), (.prod, "http://prod.api.service2.com")])
            .productionEnvironments(map: ["Service1":.env1, "Service2":.prod])
            .production()
            .build()
        
        XCTAssertEqual(em.entry(for: "Service1")?.environmentNames().count, 1)
    }
    
    func testSettingProductionEntryToFalseDoesNotUseProduction() {
        let b = Builder().setStoreType(.inMemory)
        let em = try! b
            .add(entry: "Service1", environments:[(.env1, "http://env1.api.service1.com"), (.env2, "http://env2.api.service1.com")])
            .add(entry: "Service2", environments:[(.acc, "http://acc.api.service2.com"), (.prod, "http://prod.api.service2.com")])
            .productionEnvironments(map: ["Service1":.env1, "Service2":.prod])
            .production(expression: { return false })
            .build()
        
        XCTAssertEqual(em.entry(for: "Service1")?.environmentNames().count, 2)
    }
    
    func testDefaultSortOrderIsOrderOfItemsAdded() {
        // Default is order added
        let b = Builder().setStoreType(.inMemory)
        
        let em = try! b
            .add(entry: "ZService", environments:[(.env1, "http://benv.api.zervice.com"), (.env2, "http://aenv.api.zservice.com")])
            .add(entry: "AService", environments:[(.env1, "http://benv.api.aservice.com"), (.env2, "http://aenv.api.aservice.com")])
            .build()
        
        XCTAssertEqual(em.entry(for: 0)?.name, "ZService")
        XCTAssertEqual(em.entry(for: 0)?.environment(forIndex: 0), .env1)
    }
    
    
    func testBuilderAddsOptionalStringData() {
        let b = Builder().add(entry: "Service1", environments:[(.acc, "http://env1.api.service1.com")])
            .associateData { pair -> String? in
                guard pair.environment == .acc else {
                    return nil
                }
                return "my-token"
        }
        
        let em = try! b.build()
        XCTAssertEqual(em.entry(for: "Service1")?.additionalData(for: .acc), "my-token")
    }
    
    func testBuilderAddsComplexDataObject() {
        let b = Builder().add(entry: "Service1", environments:[(.acc, "http://env1.api.service1.com")])
            .associateData { pair -> [String:[String]]? in
                guard pair.environment == .acc else {
                    return nil
                }
                return ["complex": ["data"]]
        }
        
        let em = try! b.build()
        XCTAssertEqual(em.entry(for: "Service1")?.additionalData(for: .acc), ["complex": ["data"]])
    }
}


// MARK: - Error Tests
extension BuilderTests {
    // Error checking
    // Commenting out for now. For some reason XCTAssertThrowsError is not passing even tho I verified an error is thrown from b.build(). (by trying try!, it crashes)
    func testInvalidURLThrowsError() {
        // URL Error
        let b = Builder().add(entry: "Service1", environments:[(.env1, "ht tp://env1.api.service1.com")])
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
        let b = Builder().add(entry: "Service1", environments:[(.env1, "http://env1.api.service1.com")])
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
        let b = Builder().add(entry: "Service1", environments:[(.env1, "http://env1.api.service1.com")])
            .productionEnvironments(map: ["Service1":.env2])
            .production()
        XCTAssertThrowsError(try b.build()) { (e) in
            guard let error = e as? Builder.BuildError else {
                XCTFail()
                return
            }
            switch error {
            case .EnvironmentCouldNotBeFound(let service, let name):
                XCTAssertEqual(service, "Service1")
                XCTAssertEqual(name, .env2)
            default:
                XCTFail()
            }
        }
    }
}
