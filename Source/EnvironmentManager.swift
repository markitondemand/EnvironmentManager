//
//  EnvironmentManager.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 2/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation


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
    private var entries: [String: Entry] = [:]
    
    public init() { }
    
    
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
    
    
    /// Adds a single Entry to the environment manager
    ///
    /// - Parameter entry: The entry to add
    public func add(entry: Entry) {
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
        guard var entry = self.entries[apiName] else {
            return
        }
        
        entry.currentEnvironment = environment
        self.entries[apiName] = entry
    }
}
