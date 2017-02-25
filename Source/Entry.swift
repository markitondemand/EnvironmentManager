//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// Simple datastructure represneting an API and its associated enviroments, as not all APIs will have the same number of enviromments (e.g. some may have a dev, where others wont, like client APIs)
public class Entry {
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
    public func add(pair: (environment: String, baseUrl: URL)) {
        self.add(url: pair.baseUrl, forEnvironment: pair.environment)
    }
    
    
    /// Returns an array of all environments the current entry supports. This will by default sort the names in ascending order. Pass your own sort closure to change the sorting behavior
    ///
    /// - Returns: An array of all environments for this entry
    public func environmentNames(usingSortFunction function: (String, String) -> Bool = { $0 < $1}) -> [String] {
        return Array(self.environments.keys).sorted(by: function)
    }
    
    //TOOD: do not assume ascending here... will cause issues with other functions. need to pass the sort function in or get it some other way
    /// Selects an environment at a given index. This will sort in ascending order by default
    ///
    /// - Parameter index: The index
    public func selectEnvironment(index: Int) {
        self.currentEnvironment = self.environments.sorted(by: { $0.key < $1.key })[index].key
    }
    
//    public func environmentFor(index: Int) -> String? {
//
//    }
    
//    public func baseURLForIndex(index: Int) -> URL? {
//        
//    }
}
