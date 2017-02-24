//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// Simple datastructure represneting an API and its associated enviroments, as not all APIs will have the same number of enviromments (e.g. some may have a dev, where others wont, like client APIs)
public struct Entry {
    /// The name of the API (e.g. MDQuoteService)
    public let name: String
    fileprivate var environments: [String: URL]
    
    // This variable is needed to define a backing store variable because when you override the set or get on a property they lose their backing variable
    private var backingCurrentEnvironment: String
    
    /// Get and Set the current environment. If you attempt to set the environment to something this Entry does not know about nothing will change. (i.e. this guarantees that it will always be pointing to an environment that exists within this Entry)
    public var currentEnvironment: String {
        set (newEnvironment) {
            if (self.environments.keys.contains(newEnvironment) && newEnvironment != self.backingCurrentEnvironment) {
                let oldEnvironment = self.backingCurrentEnvironment
                self.backingCurrentEnvironment = newEnvironment
                
                // @TODO: possibly use a "broadcaster" that is injected on initialization like TestAccountManager to separate notifiaction from this class
                NotificationCenter.default.post(Notification(name: Notification.Name.EnvironmentDidChange, object: self, userInfo: [EnvironmentChangedKeys.APIName:self.name,
                                                                                                                                    EnvironmentChangedKeys.OldEnvironment:oldEnvironment,
                                                                                                                                    EnvironmentChangedKeys.NewEnvironment:newEnvironment]))
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
    public init(name: String, initialEnvironment: (String, URL)) {
        environments = [initialEnvironment.0 : initialEnvironment.1]
        self.name = name
        self.backingCurrentEnvironment = initialEnvironment.0
    }
}

// MARK: - Operations
extension Entry {
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
}

// MARK: - Mutating functions
extension Entry {
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
