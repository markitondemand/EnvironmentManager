//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV
import MD_Extensions


/// Simple datastructure represneting an API and its associated enviroments, as not all APIs will have the same number of enviromments (e.g. some may have a dev, where others wont, like client APIs)
public struct Entry {
    // TOOD: fix naming
    internal struct Environment: Equatable, Hashable {
        let environment: String
        let baseUrl: URL
        
        public init(environment: String, baseUrl: URL) {
            self.environment = environment
            self.baseUrl = baseUrl
        }
        
        public init(pair: Pair) {
            self.init(environment: pair.0, baseUrl: pair.1)
        }
        
        // Hashable
        var hashValue: Int {
            return "\(environment),\(baseUrl)".hashValue
        }
        
        // Equatabe
        public static func ==(lhs: Environment, rhs: Environment) -> Bool {
            return lhs.baseUrl == rhs.baseUrl && lhs.environment == rhs.environment
        }
    }
    
    public typealias Pair = (environment: String, baseUrl: URL)
    
    /// The name of the API (e.g. MDQuoteService)
    public let name: String
    
    // Data structure to hold the environments for this Entry
    internal fileprivate(set) var environments: [Environment]
    
    /// Returns the base API for a given environment
    public func currentBaseUrlForEnvironment(_ environment: String) -> URL? {
        guard let found = self.environments.first(where: { $0.environment == environment }) else {
            return nil
        }
        return found.baseUrl
    }
    
    /// The standard initializer for an Entry
    ///
    /// - Parameters:
    ///   - name: The name of the entry, this should be something like the name of your API, (e.g. "MDQuoteService")
    ///   - initialEnvironment: The initial environment as a tuple. (e.g. acc, prod, acceptance, test, etc.) The URL should be the base URL to your service
    public init(name: String, initialEnvironment: (String, URL)) {
        environments = [Environment(pair: initialEnvironment)]
        self.name = name
    }
    
    internal init(name: String, environments: [Environment]) {
        self.name = name
        self.environments = environments
    }
    
    
    /// Initializes a new Entry with a name and a list of environments and URLs.
    ///
    /// - Parameters:
    ///   - name: The name of the Entry
    ///   - environments: The list of environments and URLs. There must be at least one element in this or an assertion is raised. The first element is used as the initial current environment
    public init(name: String, environments: [(String, URL)]) {
        precondition(environments.count > 0, "You must pass at least one environment pair.")
        var environments = environments
        self.init(name:name, initialEnvironment: environments.removeFirst())
        self.add(environments)
    }
}



// MARK: - Equatable
extension Entry: Equatable {
    public static func ==(lhs: Entry, rhs: Entry) -> Bool {
        return lhs.environments == rhs.environments &&
            lhs.name == rhs.name
    }

}


// MARK: - Operations
extension Entry {
    /// Builds a URL by appending a path to the currently selected environment's baseURL
    ///
    /// - Parameter path: The path to append
    /// - Returns: The new URL or nil if the URL could not be formed
    public func buildURLForEnvironment(_ environment: String, path: String) -> URL? {
        return self.baseUrl(forEnvironment: environment)?.appendingPathComponent(path)
    }
    
    /// Returns the base URL for a given environment, or nil if the environment does not exist for this entry
    ///
    /// - Parameter environment: The environment name
    /// - Returns: The base URL for that environment, or nil
    public func baseUrl(forEnvironment env: String) -> URL? {
        guard let index = self.environments.index(where: { $0.environment == env }) else {
            return nil
        }
        return self.environments[index].baseUrl
    }
    
    /// Returns an array of all of the current environments this manager is managing
    ///
    /// - Returns: An array of environment names.
    public func environmentNames() -> [String] {
        return self.environments.map({ $0.environment })
    }
    
    /// Attempts to select a new environment. If the environment is not currently known, or already selected no operation is performed. This does the same as setting the "currentEnvironment" variable directly
    ///
    /// - Parameter environment: The environment to try adn aselect
//    public func select(environment: String) {
//        self.currentEnvironment = environment
//    }
}


// MARK: - Index support
extension Entry {
        
    /// Returns the environment for a given index. The environemnts are put into a sorted order using a function. The default function is ascending.
    ///
    /// - Parameters:
    ///   - index: The index to search
    ///   - function: Optional paramter to override the default sort. The default is ascending
    /// - Returns: The environment as a string or nil if the index was out of bounds
    public func environment(forIndex index: Int) -> String? {
        return self.environmentNames()[safe: index]
    }
    
    /// Returns the baseURL for a given index. The baseURLs are put into a sorted order using a function. The default function is ascending.
    ///
    /// - Parameters:
    ///   - index: The index to search
    ///   - function: Optional paramter to override the default sort. The default is ascending
    /// - Returns: The base URL as a URL or nil if the index was out of bounds
    public func baseUrl(forIndex index: Int) -> URL? {
        guard let environment = self.environmentNames()[safe: index] else {
            return nil
        }
        // TOOD: refactor. This is most likely horrendously ineficient. Need to probably support sorting the actual EnvironmentPair objects
        return self.baseUrl(forEnvironment: environment)
    }
    
    /// Selects an environment at a given index. This will sort the environment by there name for selecting an index. The default sort is in ascending order
    ///
    /// - Parameter index: The index
//    public func selectEnvironment(forIndex index: Int) {
//        guard let environment = self.environmentNames()[safe: index] else {
//            return
//        }
//        self.currentEnvironment = environment
//    }
}


// MARK: - Internal mutating functions
extension Entry {
    /// Adds a new environment and corresponding baseURL to this entry
    ///
    /// - Parameters:
    ///   - url: The base URL
    ///   - environment: The environment it belongs to
    internal mutating func add(url: URL, forEnvironment environment:String) {
        self.environments.append(Environment(environment: environment, baseUrl: url))
    }
    
    /// Adds a new envvironemt and base URL to this entry
    ///
    /// - Parameter pair: The tuple representing the environment and baseUR:
    internal mutating func add(_ pair: Pair) {
        self.add(url: pair.baseUrl, forEnvironment: pair.environment)
    }
    
    
    // TOOD: unit test
    /// Adds an array of environment pairs to this Entry
    ///
    /// - Parameter pairs: The environments to add
    internal mutating func add(_ pairs: [Pair]) {
        pairs.forEach{ self.add($0) }
    }
    
    // TOOD: unit test
    @discardableResult internal mutating func removeEnvironment(_ name: String) -> Bool {
        guard let index = environments.index(where:{ $0.environment == name }) else {
            return false
        }
        environments.remove(at: index)
        return true
    }
}

// MARK: - Storage to DataStore
extension Entry {
    func writeToStore(_ store: DataStore) {
        var store = store
        
        
        if store["CustomEntryStorage"] == nil {
            store["CustomEntryStorage"] = [[String: Any]]()
        }
        
        var array = store["CustomEntryStorage"] as! [[String: Any]]
        array.append(self.serialize())
        store["CustomEntryStorage"] = array
    }
    
    // TOOD: port Entry to `Codeable` in swift 4
    private func serialize() -> [String: [[String: String]]] {
        let name = self.name
        let pairs = self.environments
        return [name: pairs.map { [$0.environment: $0.baseUrl.absoluteString] }]
    }
}
