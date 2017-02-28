//
//  EnvironmentManager.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 2/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import MD_Extensions


public extension Notification.Name {
    /// This notification is posted if the environment for an API changes. The old environment, new environment, and the name of the environment. Please see EnvironmentChangedKeys for info on what is passed. The object that posts this will be the Entry item that was changed.
    static let EnvironmentDidChange = Notification.Name("EnvironmentDidChange")
}


/// Keys that can be accessed from the "userInfo" dictionary of the EnvironmentDidChange Notification
///
/// - APIName: The key to access what the name of the API that is changing
/// - OldEnvironment: The key to access what the old environment was
/// - NewEnvironment: The key to access what the new environment will be
public enum EnvironmentChangedKeys: String {
    case APIName
    case OldEnvironment
    case NewEnvironment
}

/// This is the main class of the EnvironmentManager
public class EnvironmentManager {
    public let store: DataStore
    
    /// Helper class used to serialize the seleced environments
    internal class SavedEnvironments: NSObject, NSCoding {
        private var currentEnvironments: [String:String]
        
        override required init() {
            currentEnvironments = [:]
        }
        required init?(coder: NSCoder) {
            guard let currentEnvironments = coder.decodeObject(forKey: "Environments") as? Dictionary<String,String> else {
                return nil
            }
            self.currentEnvironments = currentEnvironments
        }
        
        func encode(with coder: NSCoder) {
            coder.encode(self.currentEnvironments, forKey:"Environments")
        }
        
        internal func store(service: String, forEnvironment environment: String) {
            self.currentEnvironments[service] = environment
        }
        
        internal func environment(forService service: String) -> String? {
            return self.currentEnvironments[service]
        }
    }
    
    internal static let privateStoreKey = "com.markit.EnvironmentMenanager"
    fileprivate var entries: [String: Entry] = [:]
    
    
    /// Createsa a new EnvironmentManager using a
    ///
    /// - Parameters:
    ///   - initialEntries: The initial entries to use
    ///   - backingStore: The store to load persisted environment from (if applicable). The user defualts will be checked by default
    public init(initialEntries: [Entry] = [], backingStore: DataStore = UserDefaultsStore()) {
        self.store = backingStore
        let savedEnvironments: SavedEnvironments
        if let data = backingStore[EnvironmentManager.privateStoreKey] as? Data {
            NSKeyedUnarchiver.setClass(SavedEnvironments.self, forClassName: "SavedEnvironments")
            savedEnvironments = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedEnvironments ?? SavedEnvironments()
        }
        else {
            savedEnvironments = SavedEnvironments()
        }
        
        for entry in initialEntries {
            let environment = savedEnvironments.environment(forService: entry.name) ?? entry.currentEnvironment
            entry.backingCurrentEnvironment = environment
            self.add(entry: entry)
        }
    }
    
    /// Attempts to save the current environments to a given store. If no store is provided the one used when creating this instance will be used instead
    ///
    /// - Parameter store: The store to save the selected environments to
    public func save(usingStore store: DataStore? = nil) {
        var store = store ?? self.store
        let savedEnv = SavedEnvironments()
        for entry in self.entries {
            savedEnv.store(service: entry.key, forEnvironment: entry.value.currentEnvironment)
        }
        
        store[EnvironmentManager.privateStoreKey] = NSKeyedArchiver.archivedData(withRootObject: savedEnv)
    }
    
    
    /// Returns an ordered list of all of the API names currently managed. By default the list will be returned in ascending order but you can optionally sort them in another way (i.e. descending)
    ///
    /// - Returns: The names of all APIs currently managed
    public func apiNames(usingSortFunction function: (String, String) -> Bool = { $0 < $1}) -> [String] {
        return Array(self.entries.keys).sorted(by: function)
    }
    
    /// Builds a full URL for a given base API.
    ///
    /// - Parameters:
    ///   - apiName: The name of the API (e.g. MDQuoteService)
    ///   - path: The path to the resource. This will be appended to the base URL
    /// - Returns: A new URL for use or nil if the URL could not be created or the API is not found in the manager
    public func urlFor(apiName: String, path: String) -> URL? {
        guard let entry = entries[apiName] else {
            return nil
        }
        return entry.buildURLWith(path: path)
    }
    
    
    /// Gets the current selecterd environment for a given API as a string.
    ///
    /// - Parameter apiName: The name of the API to check what the currently selected environment is
    /// - Returns: The environment name, or nil if that API name is not registered with the manager
    public func currentEnvironmentFor(apiName: String) -> String? {
        return self.entries[apiName]?.currentEnvironment
    }
    
    
    /// Returns the current base URL of a given API.
    ///
    /// - Parameter apiName: The name of the API
    /// - Returns: A base URL or nil if that API name cannot be found
    public func baseUrl(apiName: String) -> URL? {
        return self.entries[apiName]?.currentBaseUrl
    }
    
    
    /// Adds a single Entry to the environment manager. If the entry was persisted to the store that was passed on creation, it will update the current environment to match what the store has.
    ///
    /// - Parameter entry: The entry to add
    public func add(entry: Entry) {
        // check if the entry was saved previously
        if let environment = self.store.environment(forService: entry.name) {
            entry.backingCurrentEnvironment = environment
        }
        self.entries[entry.name] = entry
    }
    
    /// Adds a list of entries for a given API
    ///
    /// - Parameters:
    ///   - apiName: The API name (e.g. MDQuoteService)
    ///   - environmentUrls: An array of tuples that match an environment string to a given URL. The first element in the array will become the current environment for that API. This must be an array with more than 0 eleemnts
    public func add(apiName: String, environmentUrls:[(environment: String, baseUrl: URL)]) {
        precondition(!environmentUrls.isEmpty, "Error, input URLs for given entry was empty! Plesae provide at least one environment and corresponding url")
        
        var entry: Entry!
        for pair in environmentUrls {
            if (entry == nil) {
                entry = Entry(name: apiName, initialEnvironment: pair)
            }
            else {
                entry.add(pair: pair)
            }
        }
        self.add(entry: entry)
    }
    
    /// Attempts to select a new environment for a given API. If the environment succefully changes for an API a notification will be posted. Please see the "EnvironmentDidChange": notifcation
    ///
    /// - Parameters:
    ///   - environment: The environment to select
    ///   - apiName: The API to select the environment for
    public func select(environment: String, forAPI apiName: String) {
        if (!self.entries.keys.contains(apiName)) {
            return
        }
        guard let entry = self.entries[apiName] else {
            return
        }
        
        entry.currentEnvironment = environment
    }
    
    
    /// Attempts to return the Entry instasnce for a given service name. Nil is returned if the service does not exist in the manager
    ///
    /// - Parameter service: The name of the service
    /// - Returns: The corresponding Entry or nil
    public func entry(forService service: String) -> Entry? {
        return self.entries[service]
    }
}

// MARK: - Index and IndexPath support
extension EnvironmentManager {
    public func entry(forIndex index: Int) -> Entry? {
        guard let environment = self.apiNames()[safe: index] else {
            return nil
        }
        return self.entries[environment]
    }
    
//    func url(forIndexPath path: IndexPath) -> URL? {
//        
//    }
//    func environment(forIndexPath path: IndexPath) -> URL? {
//        
//    }
}


// MARK: - Convenience extension for access the our data from the DataStore
extension DataStore {
    func environment(forService service: String) -> String? {
        guard let data = self[EnvironmentManager.privateStoreKey] as? Data else {
            return nil
        }
        let savedEnvironment = NSKeyedUnarchiver.unarchiveObject(with: data) as? EnvironmentManager.SavedEnvironments
        return savedEnvironment?.environment(forService: service)
    }
}
