//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class BundleTests: XCTestCase {
    func testStoryboardName() {
        XCTAssertEqual(UIStoryboard.environmentManagerStoryboardName, "EnvironmentManagerStoryboard")
    }
    
    func testResourceBundleIsRetrievable() {
        XCTAssertNotNil(BundleAccessor().resourceBundle)
    }
    
    func testStoryboardIsRetrievable() {
        XCTAssertNotNil(UIStoryboard.environmentManagerStoryboard)
    }
    
    func testInstantiatesViewController() {
        let em = EnvironmentManager(backingStore: DictionaryStore())
        
        XCTAssertNotNil(em.generateViewController())
    }
}
