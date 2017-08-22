//
//  EnvironmentStore.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 8/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

class EnvironmentStore {
    var backingStore: DataStore
    
    init(backingStore: DataStore = DictionaryStore()) {
        self.backingStore = backingStore
    }
    
    public func currentlySelectedEnvironmentFor(_ entry: Entry) -> String {
        return backingStore[entry.name] as? String ?? entry.environments.first!.environment
    }
    
    public func selectEnvironment(_ environment: String, for entry: Entry) {
        let found = entry.environments.map { $0.environment }.first(where: { $0 == environment })
        let oldEnvironment = self.currentlySelectedEnvironmentFor(entry)
        
        if found != nil && oldEnvironment != environment {
            backingStore[entry.name] = found
            // @TODO: possibly use a "broadcaster" that is injected on initialization like TestAccountManager to separate NotificationCenter from this class
            self.broadcastEnvironmentChange(entry.name, old: oldEnvironment, new: found!)
        }
    }
    
    public func buildUrl(for entry: Entry, path: String) -> URL {
        let selectedEnvironment = currentlySelectedEnvironmentFor(entry)
        return entry.baseUrl(forEnvironment: selectedEnvironment)!.appendingPathComponent(path)
    }
    
    // TOOD: unit test
    public func baseUrl(for entry: Entry) -> URL {
        let selectedEnvironment = currentlySelectedEnvironmentFor(entry)
        return entry.baseUrl(forEnvironment: selectedEnvironment)!
    }
    
    
    // TOOD: unit test better
    // Get and Set the current environment. If you attempt to set the environment to something this Entry does not know about nothing will change. (i.e. this guarantees that it will always be pointing to an environment that exists within this Entry)
    private func broadcastEnvironmentChange(_ apiName: String, old: String, new: String) {
        NotificationCenter.default.post(Notification(name: Notification.Name.EnvironmentDidChange, object: self, userInfo: [EnvironmentChangedKeys.APIName:apiName,
                                                                                                                            EnvironmentChangedKeys.OldEnvironment:old,
                                                                                                                            EnvironmentChangedKeys.NewEnvironment:new]))
    }
}
