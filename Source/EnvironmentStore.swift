//
//  EnvironmentStore.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 8/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation


/// This class manages storing selected environments
class EnvironmentStore {
    var backingStore: DataStore
    
    init(backingStore: DataStore) {
        self.backingStore = backingStore
    }
    
    func currentlySelectedEnvironmentFor(_ entry: Entry) -> String {
        guard let stored = backingStore[entry.name] as? String,
            // verify the environment in the store is also still in the entry
            entry.environmentNames().contains(stored) else {
                // TODO: safely return the 0th (force unwrap should probably be removed but we guarantee this at construction, but possible refactor might be to change the dataStore for environments to a new array type that can only be created with 1 or more items)
                return entry.environments.first!.environment
        }
        return stored
    }
    
    func selectEnvironment(_ environment: String, for entry: Entry) {
        let found = entry.environments.map { $0.environment }.first(where: { $0 == environment })
        let oldEnvironment = self.currentlySelectedEnvironmentFor(entry)
        
        if found != nil && oldEnvironment != environment {
            backingStore[entry.name] = found
            // @TODO: possibly use a "broadcaster" that is injected on initialization like TestAccountManager to separate NotificationCenter from this class
            self.broadcastEnvironmentChange(entry.name, old: oldEnvironment, new: found!)
        }
    }
    
    func buildUrl(for entry: Entry, path: String) -> URL {
        let selectedEnvironment = currentlySelectedEnvironmentFor(entry)
        return entry.baseUrl(for: selectedEnvironment)!.appendingPathComponent(path)
    }
    
    // TOOD: unit test
    func baseUrl(for entry: Entry) -> URL {
        let selectedEnvironment = currentlySelectedEnvironmentFor(entry)
        // TOOD: not a big fan of this force unwrap. Its kind of all built around an assumption that an Entry cannot be created with 0 environments (you will always have at least one, or the item doesnt get made)
        return entry.baseUrl(for: selectedEnvironment)!
    }
    
    
    // TOOD: unit test better
    // Get and Set the current environment. If you attempt to set the environment to something this Entry does not know about nothing will change. (i.e. this guarantees that it will always be pointing to an environment that exists within this Entry)
    private func broadcastEnvironmentChange(_ apiName: String, old: String, new: String) {
        NotificationCenter.default.post(Notification(name: Notification.Name.EnvironmentDidChange, object: self, userInfo: [EnvironmentChangedKeys.APIName:apiName,
                                                                                                                            EnvironmentChangedKeys.OldEnvironment:old,
                                                                                                                            EnvironmentChangedKeys.NewEnvironment:new]))
    }
}
