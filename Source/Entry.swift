//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// Simple datastructure represneting an API and its associated enviroments, as not all APIs will have the same number of enviromments (e.g. some may have a dev, where others wont, like client APIs)
public class Entry {
    // Types
    public typealias SortSignature = (String, String) -> Bool
    public typealias Pair = (environment: String, baseUrl: URL)
    
    // Sort ascending by default
    fileprivate static var DefaultSort: SortSignature = { $0 < $1 }
    
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
    
    
    /// Returns the base API for the currently selected environment
    public var currentBaseUrl: URL {
        get {
            // We guarantee elsewhere that the currentEnvironment will always exist in the dictionary. There might be a way to use the "Dictionary.Index" stuff to access the value directly instead of force unwrapping the optional
            return self.environments[self.currentEnvironment]!
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
    
    /// Adds a new environment and corresponding baseURL to this entry
    ///
    /// - Parameters:
    ///   - url: The base URL
    ///   - environment: The environment it belongs to
    public func add(url: URL, forEnvironment environment:String) {
        self.environments[environment] = url
    }
    
    /// Adds a new envvironemt and base URL to this entry
    ///
    /// - Parameter pair: The tuple representing the environment and baseUR:
    public func add(pair: Pair) {
        self.add(url: pair.baseUrl, forEnvironment: pair.environment)
    }
    
    
    /// Returns an array of all environments the current entry supports. This will by default sort the names in ascending order. Pass your own sort closure to change the sorting behavior
    ///
    /// - Returns: An array of all environments for this entry
    public func environmentNames(usingSortFunction function: SortSignature = DefaultSort) -> [String] {
        return Array(self.environments.keys).sorted(by: function)
    }
    
    
    /// Attempts to select a new environment. If the environment is not currently known, or already selected no operation is performed. This does the same as setting the "currentEnvironment" variable directly
    ///
    /// - Parameter environment: The environment to try adn aselect
    public func select(environment: String) {
        self.currentEnvironment = environment
    }
    
    /// Selects an environment at a given index. This will sort the environment by there name for selecting an index. The default sort is in ascending order
    ///
    /// - Parameter index: The index
    public func selectEnvironment(forIndex index: Int, usingSortFunction function: SortSignature = DefaultSort) {
        guard let environment = self.environments.keys.sorted(by: function)[safe: index] else {
            return
        }
        self.currentEnvironment = environment
    }
}


// MARK: - Index and IndexPath support
extension Entry {
    
    /// Returns the environment for a given index. The environemnts are put into a sorted order using a function. The default function is ascending.
    ///
    /// - Parameters:
    ///   - index: The index to search
    ///   - function: Optional paramter to override the default sort. The default is ascending
    /// - Returns: The environment as a string or nil if the index was out of bounds
    public func environment(forIndex index: Int, usingSortFunction function: SortSignature = DefaultSort) -> String? {
        return self.environmentNames(usingSortFunction: function)[safe: index]
    }
    
    
    /// Returns the baseURL for a given index. The baseURLs are put into a sorted order using a function. The default function is ascending.

    ///
    /// - Parameters:
    ///   - index: The index to search
    ///   - function: Optional paramter to override the default sort. The default is ascending
    /// - Returns: The base URL as a URL or nil if the index was out of bounds
    public func baseURL(forIndex index: Int, usingSortFunction function: SortSignature = DefaultSort) -> URL? {
        guard let environment = self.environment(forIndex: index, usingSortFunction: function) else {
            return nil
        }
        return self.environments[environment]
    }
}
