//  Copyright © 2017 Markit. All rights reserved.
//

import XCTest
@testable import MDEnvironmentManager

class BundleTests: XCTestCase {
    
    func testResourceBundleIsRetrievable() {
        XCTAssertNotNil(BundleAccessor.bundle())
    }
    
    func testStoryboardIsRetrievable() {
        XCTAssertNotNil(UIStoryboard.environmentManagerStoryboard)
        XCTAssertNotNil(UIStoryboard.environmentManagerStoryboard.instantiateInitialViewController())
    }
}
