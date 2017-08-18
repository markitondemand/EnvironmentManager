//
//  CustomEnvironments.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 8/17/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation


class CustomEnvironments {
    private static let CustomEnvironmentsKey = "com.markit.environmentManager.CustomEnvironmentsKey"
    var store: DataStore
    
    init(_ store: DataStore) {
        var store = store
        if store[CustomEnvironments.CustomEnvironmentsKey] == nil {
            store[CustomEnvironments.CustomEnvironmentsKey] = [Entry]()
        }
        
        self.store = store
    }
    
    func addPermanentEntry(_ entry: Entry) {
        entry.writeToStore(self.store)
    }
}
