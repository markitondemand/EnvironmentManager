//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import XCTest

@testable import MDEnvironmentManager

class CSVTests: XCTestCase {
    var oneEnvCSV: String {
        return "Name|Environment|BaseURL\nService1|Acc|http://acc.api.service1.com"
    }
    
    var twoEnvCSV: String {
        return oneEnvCSV.appending("\nService1|Prod|http://prod.api.service1.com")
    }
    
    func testCreateOneEnvironmentFromCSV() {

        let em = EnvironmentManager(csv: self.oneEnvCSV)
        
        let entry = em?.entry(forService: "Service1")
        XCTAssertEqual(entry?.name, "Service1")
        XCTAssertEqual(entry?.currentEnvironment, "Acc")
        XCTAssertEqual(entry?.currentBaseUrl, URL(string: "http://acc.api.service1.com")!)
        
    }
    
    func testCreateMultiEnvironmentFromCSV() {
        let em = EnvironmentManager(csv: self.twoEnvCSV)
        
        let entry = em?.entry(forService: "Service1")
        
        XCTAssertEqual(entry?.environmentNames().count, 2)
    }
}
