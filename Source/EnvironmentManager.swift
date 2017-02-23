//
//  EnvironmentManager.swift
//  MDEnvironmentManager
//
//  Created by Michael Leber on 2/22/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation




// TODO:
// Notifications
//  send the followng on environment change
//  1. what was OLD env
//  2. what is NEW env
//  3. some context so that the watcher can grab the correct base URL (i.e. multiple URL entries for a single environment)
public extension Notification.Name {
    /// This notification is posted if the environment for an API changes. The old environment, new environment, and
    static let EnvironmentDidChange = Notification.Name("EnvironmentDidChange")
}


/// This is the main class of the EnvironmentManager
public class EnvironmentManager {
    private var entries: [String: Entry] = [:]
    
    
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
    
    //@TODO: notification broadcasting
    /// Attempts to select a new environment for a given API. If the environment succefully changes for an API a notification will be posted. Please see the "EnvironmentDidChange": notifcation
    ///
    /// - Parameters:
    ///   - environment: The environment to select
    ///   - apiName: The API to select the environment for
    func select(environment: String, forAPI apiName: String) {
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


/// Simple datastructure represneting an API and its associated enviroments, as not all APIs will have the same number of enviromments (e.g. some may have a dev, where others wont, like client APIs)
public struct Entry {
    
    /// The name of the API (e.g. MDQuoteService)
    let name: String
    private var environments: [String: URL]
    
    // This variable is needed to define a backing store variable because when you override the set or get on a property they lose their backing variable
    private var backingCurrentEnvironment: String!
    
    /// Get and Set the current environment. If you attempt to set the environment to something this Entry does not know about nothing will change. (i.e. this guarantees that it will always be pointing to an environment that exists within this Entry)
    public var currentEnvironment: String {
        set (value) {
            if (self.environments.keys.contains(value)) {
                self.backingCurrentEnvironment = value
            }
        }
        get {
            return self.backingCurrentEnvironment
        }
    }
    
    
    /// The standard initializer for an Entry
    ///
    /// - Parameters:
    ///   - name: The name of the entry, this should be something like the name of your API, (e.g. "MDQuoteService")
    ///   - initialEnvironment: The initial environment. (e.g. acc, prod, acceptance, test, etc.
    init(name: String, initialEnvironment: (String, URL)) {
        environments = [initialEnvironment.0 : initialEnvironment.1]
        self.name = name
        self.backingCurrentEnvironment = initialEnvironment.0
    }
    
    
    /// Builds a URL by appending a path to the currently selected environment's baseURL
    ///
    /// - Parameter path: The path to append
    /// - Returns: The new URL or nil if the URL could not be formed
    public func buildURLWith(path: String) -> URL? {
        guard let baseURL = self.environments[self.currentEnvironment] else {
            return nil
        }
        return baseURL.appendingPathComponent(path)
    }
    
    /// Adds a new environment and corresponding baseURL to this entry
    ///
    /// - Parameters:
    ///   - url: The base URL
    ///   - environment: The environment it belongs to
    public mutating func add(url: URL, forEnvironment environment:String) {
        self.environments[environment] = url
    }
    
    /// Adds a new envvironemt and base URL to this entry
    ///
    /// - Parameter pair: The tuple representing the environment and baseUR:
    public mutating func add(pair: (environment: String, baseUrl: URL)) {
        self.add(url: pair.baseUrl, forEnvironment: pair.environment)
    }
}
