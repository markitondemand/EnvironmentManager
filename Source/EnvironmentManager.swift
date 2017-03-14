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

/// This is the main class of the EnvironmentManager. To create one please use a Builder() instance.
public class EnvironmentManager {
    public let store: DataStore    
    fileprivate var entries: [Entry] = []
    
    
    /// Createsa a new EnvironmentManager using an array of pre created Entry objects.
    ///
    /// - Parameters:
    ///   - initialEntries: The initial entries to use
    ///   - backingStore: The store to load persisted environment from (if applicable). The user defaults will be used to read and write environment information to by default
    internal init(initialEntries: [Entry] = [], backingStore: DataStore = UserDefaultsStore()) {
        self.store = backingStore
        let environments = self.store.readEnvironments()
        for entry in initialEntries {
            let environment = environments[entry.name] ?? entry.currentEnvironment
            entry.backingCurrentEnvironment = environment
            self.add(entry: entry)
        }
    }
    
    /// Attempts to save the current environments to the store passed at creation.
    public func save() {
        var store = self.store

        // Reduce our entries to a dictionary of service names -> current environment
        let reduced = self.entries.reduce([:]) { (dict, entry: Entry) -> [String: String] in
            var dict = dict
            dict[entry.name] = entry.currentEnvironment
            return dict
        }
        
        store.write(environments:reduced)
    }
    
    
    /// Returns an ordered list of all of the API names currently managed. By default the list will be returned in ascending order but you can optionally sort them in another way (i.e. descending)
    ///
    /// - Returns: The names of all APIs currently managed
    public func apiNames() -> [String] {
        return self.entries.map({ $0.name })
    }
    
    /// Builds a full URL for a given base API.
    ///
    /// - Parameters:
    ///   - apiName: The name of the API (e.g. MDQuoteService)
    ///   - path: The path to the resource. This will be appended to the base URL
    /// - Returns: A new URL for use or nil if the URL could not be created or the API is not found in the manager
    public func urlFor(apiName: String, path: String) -> URL? {
        guard let singleEntry = self.entry(forService: apiName) else {
            return nil
        }
        return singleEntry.buildURLWith(path: path)
    }
    
    
    /// Gets the current selecterd environment for a given API as a string.
    ///
    /// - Parameter apiName: The name of the API to check what the currently selected environment is
    /// - Returns: The environment name, or nil if that API name is not registered with the manager
    public func currentEnvironmentFor(apiName: String) -> String? {
        return self.entries.first(where: { $0.name == apiName })?.currentEnvironment
    }
    
    
    /// Returns the current base URL of a given API.
    ///
    /// - Parameter apiName: The name of the API
    /// - Returns: A base URL or nil if that API name cannot be found
    public func baseUrl(apiName: String) -> URL? {
        return self.entries.first(where: { $0.name == apiName })?.currentBaseUrl
    }
    
    /// Attempts to select a new environment for a given API. If the environment succefully changes for an API a notification will be posted. Please see the "EnvironmentDidChange": notifcation
    ///
    /// - Parameters:
    ///   - environment: The environment to select
    ///   - apiName: The API to select the environment for
    public func select(environment: String, forAPI apiName: String) {
        guard let entry = self.entry(forService: apiName) else {
            return
        }
        
        entry.currentEnvironment = environment
    }
    
    
    /// Attempts to return the Entry instasnce for a given service name. Nil is returned if the service does not exist in the manager
    ///
    /// - Parameter service: The name of the service
    /// - Returns: The corresponding Entry or nil
    public func entry(forService service: String) -> Entry? {
        return self.entries.first(where: { $0.name == service })
    }
    
}

// MARK: - Index and IndexPath support
extension EnvironmentManager {
    public func entry(forIndex index: Int) -> Entry? {
        return self.entries[safe: index]
    }
    
//    func url(forIndexPath path: IndexPath) -> URL? {
//        
//    }
//    func environment(forIndexPath path: IndexPath) -> URL? {
//        
//    }
}


// MARK: - Mutators - internal. Use Builder() to add entries
extension EnvironmentManager {
    /// Adds a single Entry to the environment manager. If the entry was persisted to the store that was passed on creation, it will update the current environment to match what the store has.
    ///
    /// - Parameter entry: The entry to add
    internal func add(entry: Entry) {
        // check if the entry was saved previously
        if let environment = self.store.environment(forService: entry.name) {
            entry.backingCurrentEnvironment = environment
        }
        //TOOD: dont allow multiple of the same env name - overwrite old one if new one w/ matching name coems in - write test
        self.entries.append(entry)
    }
    
    /// Adds a list of entries for a given API
    ///
    /// - Parameters:
    ///   - apiName: The API name (e.g. MDQuoteService)
    ///   - environmentUrls: An array of tuples that match an environment string to a given URL. The first element in the array will become the current environment for that API. This must be an array with more than 0 eleemnts
    internal func add(apiName: String, environmentUrls:[(environment: String, baseUrl: URL)]) {
        precondition(!environmentUrls.isEmpty, "Error, input URLs for given entry was empty! Plesae provide at least one environment and corresponding url")
        var environmentUrls = environmentUrls
        
        // Bad logic
        let entry = self.entry(forService: apiName) ?? Entry(name: apiName, initialEnvironment: environmentUrls.removeFirst())
        
        for pair in environmentUrls {
            entry.add(pair: pair)
        }
        self.add(entry: entry)
    }
}


// MARK: - Convenience extension for accessing our data from the DataStore
internal extension DataStore {
    internal var privateStoreKey: String {
         return "com.markit.EnvironmentMenanager"
    }

    func environment(forService service: String) -> String? {
        return self.readEnvironments()[service]
    }
    
    mutating func write(environments: [String: String]) {
        self[privateStoreKey] = environments
    }
    
    func readEnvironments() -> [String: String] {
        guard let environmentsDictionary = self[privateStoreKey] as? [String: String] else {
            return [:]
        }
        return environmentsDictionary
    }
}
