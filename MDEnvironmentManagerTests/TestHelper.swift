//
//  TestHelper.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 8/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
@testable import MDEnvironmentManager

// helper
func generateTestEntry(_ name: String = "Test", environmentCount: Int = 1) -> Entry {
    var environments: [Entry.EnvironmentDetail] = []
    for i in 1...environmentCount {
        environments.append(Entry.EnvironmentDetail(environment: "EV\(i)", baseUrl: URL(string: "ev\(i).\(name).com".lowercased())!))
    }
    
    return Entry(name: name, environments: environments)
}

extension URL {
    static var testURL: URL {
        return URL(string: "http://test.api.com")!
    }
}
