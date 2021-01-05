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
    
    /// The current backing store this EnvironmentManager is using. Passed in the initializer
    internal var store: DataStore

    var entries: [Entry] = []

    private var environmentStore: EnvironmentStore

    
    /// Createsa a new EnvironmentManager using an array of pre created Entry objects.
    ///
    /// - Parameters:
    ///   - initialEntries: The initial entries to use
    ///   - backingStore: The store to load persisted environment from (if applicable). The user defaults will be used to read and write environment information to by default
    internal init(_ initialEntries: [Entry] = [], backingStore: DataStore) {
        store = backingStore
        environmentStore = EnvironmentStore(backingStore: backingStore)
        for entry in initialEntries {
            self.add(entry)
        }
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
    public func url(for apiName: String, path: String) -> URL? {
        guard let entry = self.entry(for: apiName) else {
            return nil
        }
        
        return environmentStore.buildUrl(for: entry, path: path)
    }
    
    
    /// Gets the current selecterd environment for a given API as a string.
    ///
    /// - Parameter apiName: The name of the API to check what the currently selected environment is
    /// - Returns: The environment name, or nil if that API name is not registered with the manager
    public func currentEnvironment(for apiName: String) -> String? {
        guard let entry = self.entries.first(where: {$0.name == apiName }) else {
            return nil
        }
        
        return environmentStore.currentlySelectedEnvironmentFor(entry)
    }
    
    
    /// Returns the current base URL of a given API.
    ///
    /// - Parameter apiName: The name of the API
    /// - Returns: A base URL or nil if that API name cannot be found
    public func baseUrl(for apiName: String) -> URL? {
        guard let entry = self.entries.first(where: { $0.name == apiName }) else {
            return nil
        }
        
        // remove training /
        return environmentStore.baseUrl(for: entry)
    }
    
    /// Attempts to select a new environment for a given API. If the environment succefully changes for an API a notification will be posted. Please see the "EnvironmentDidChange": notifcation
    ///
    /// - Parameters:
    ///   - environment: The environment to select
    ///   - apiName: The API to select the environment for
    public func select(environment: Environment, forAPI apiName: String) {
        guard let entry = self.entries.first(where: { $0.name == apiName }) else {
            return
        }
        
        environmentStore.selectEnvironment(environment, for: entry)
    }
    
    
    /// Attempts to return the Entry instasnce for a given service name. Nil is returned if the service does not exist in the manager
    ///
    /// - Parameter service: The name of the service
    /// - Returns: The corresponding Entry or nil
    public func entry(for service: String) -> Entry? {
        return self.entries.first(where: { $0.name == service })
    }
}

// MARK: - Index and IndexPath support
extension EnvironmentManager {
    
    /// Returns an entry from a given index. this only cares about entries passed on creation from the Builder or the .csv file
    public func entry(for index: Int) -> Entry? {
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
    /// Adds a single Entry to the environment manager. If the entry's selected environment was persisted to the store in the past, it will update the current environment to match what the store has.
    ///
    /// - Parameter entry: The entry to add
    internal func add(_ entry: Entry) {
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
        // Might be better to have another helper function handle merging of already existing entries, instead of having this logic here
        var entry = self.entry(for: apiName) ?? Entry(name: apiName, initialEnvironment: environmentUrls.removeFirst())
        
        for pair in environmentUrls {
            entry.add(pair)
        }
        self.add(entry)
    }
    
    internal func replace(with entry: Entry) {
        self.entries.replace(entry)
    }
}


// MARK: - Convenience extension for accessing our data from the DataStore
internal extension DataStore {
    private var privateStoreKey: String {
         return "com.markit.EnvironmentMenanager"
    }

    func environment(for service: String) -> String? {
        return self.readEnvironments()[service]
    }
    
    mutating func write(_ environments: [String: String]) {
        var dictionary = readEnvironments()
        dictionary += environments
        self[privateStoreKey] = dictionary
    }
    
    
    func readEnvironments() -> [String: String] {
        guard let environmentsDictionary = self[privateStoreKey] as? [String: String] else {
            return [:]
        }
        return environmentsDictionary
    }
}
