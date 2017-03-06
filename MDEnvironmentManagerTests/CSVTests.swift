//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import XCTest

@testable import MDEnvironmentManager


class CSVTests: XCTestCase {
    typealias CSVLineItem = (String, String, String)
    
    // Helper defaults
    struct Defaults {
        static let defaultEnvironment = "Env1"
        static let defaultService = "Service1"
        static func defaultBaseUrl(service: String = defaultService, environment: String = defaultEnvironment) -> String {
            return "http://\(environment).api.\(service).com".lowercased()
        }
    }

    // Helper
    func CSVRow(name: String, environment: String, baseURL: String) -> CSVLineItem {
        return (name, environment, baseURL)
    }
    
    func createCSV(rows:[CSVLineItem]) -> String {
        var CSV = "Name|Environment|BaseURL"
        
        for row in rows {
            CSV.append("\n\(row.0)|\(row.1)|\(row.2)")
        }
        return CSV
    }
    
    // Convenience functions for quickly adding environments or services to an array of CSV line items.
    // This isn't perfect and requires at least 1 of each environment or it may not add the items. I dont really want to fix this as it is just a helper for quickly adding entries to an array before making my dummy csv data.
    func add(services: Int = 1, environments: Int = 1, array: inout [CSVLineItem]) {
        for i in 1...services {
            let serviceString = "Service\(i)"
            for j in 1...environments {
                let environmentString = "Env\(j)"
                array.append((serviceString, environmentString, Defaults.defaultBaseUrl(service: serviceString, environment: environmentString)))
            }
        }
        
    }
    
    // MARK: - Test Cases
    func testCreateOneEnvironmentFromCSV() {

        let em = EnvironmentManager(self.createCSV(rows:[("Service1", "Env1", "http://env1.api.service1.com")]))
        
        let entry = em?.entry(forService: "Service1")
        XCTAssertEqual(entry?.name, "Service1")
        XCTAssertEqual(entry?.currentEnvironment, "Env1")
        XCTAssertEqual(entry?.currentBaseUrl, URL(string: "http://env1.api.service1.com")!)
        
    }
    
    func testCreateMultiEnvironmentFromCSV() {
        var csvItems: [CSVLineItem] = []
        self.add(services: 1, environments: 2, array: &csvItems)
        
        let em = EnvironmentManager(self.createCSV(rows: csvItems))
        
        let entry = em?.entry(forService: "Service1")
        
        XCTAssertEqual(entry?.environmentNames().count, 2)
    }
    
    func testCreateMultiServiceOneEnvironmnetFromCSV() {
        var csvItems: [CSVLineItem] = []
        self.add(services: 2, environments: 1, array: &csvItems)
        
        let em = EnvironmentManager(self.createCSV(rows: csvItems))
        let entryTwo = em?.entry(forService: "Service2")
        
        XCTAssertEqual(entryTwo?.currentBaseUrl.absoluteString, "http://env1.api.service2.com")
    }
    
    func testCreateMultiServiceMultiEnvironmentsFromCSV() {
        
        var entries: [(String, String, String)] = []
        self.add(services: 2, environments: 2, array: &entries)
        
        let csv = self.createCSV(rows: entries)
        
        let em = EnvironmentManager(csv)
        let entryTwo = em?.entry(forService: "Service2")
        
        XCTAssertEqual(entryTwo?.currentBaseUrl.absoluteString, "http://env1.api.service2.com")
        XCTAssertEqual(entryTwo?.environment(forIndex: 1), "Env2")
    }
    
    func testComplexCSV() {
        let csvString =
            "Name|Environment|BaseURL" +
            "\nService1|Acc|http://url.com" +
            "\nService1|Prod|http://url.com" +
            "\nService1|PreProd|http://url.com" +
            "\nService2|Prod|http://url.com" +
            "\nService3|Acc|http://url.com"
        
        let em = EnvironmentManager(csvString)
        
        XCTAssertEqual(em?.apiNames().count, 3)
        XCTAssertEqual(em?.entry(forService: "Service1")?.currentEnvironment, "Acc")
        XCTAssertEqual(em?.entry(forService: "Service1")?.environmentNames().count, 3)
    }
}

