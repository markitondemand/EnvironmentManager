//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class BundleTests: XCTestCase {
    
    func testResourceBundleIsRetrievable() {
        // Cant test this as test is dependent on resources copied via pod install
//        XCTAssertNotNil(BundleAccessor().resourceBundle)
    }
    
    func testStoryboardIsRetrievable() {
//        XCTAssertNotNil(UIStoryboard.environmentManagerStoryboard)
//        XCTAssertNotNil(UIStoryboard.environmentManagerStoryboard.instantiateInitialViewController())
    }
}
