//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV
import MD_Extensions




/// Represents an app environmnt, you can create your own extension on this type and define static variables which can then be used in the following way `.myEnvironment`
public typealias Environment = String

/// Simple datastructure represneting an API and its associated enviroments, as not all APIs will have the same number of enviromments (e.g. some may have a dev, where others wont, like client APIs)
public struct Entry: Codable {
    
    /// Represents an environment, matched to a URL
    internal struct EnvironmentDetail: Equatable, Hashable, Codable {        
        let environment: String
        let baseUrl: URL
        private(set) var associatedData: Data?
        
        var asPair: Pair {
            return (environment, baseUrl)
        }
        
        init(environment: String, baseUrl: URL, data: Data? = nil) {
            self.environment = environment
            self.baseUrl = baseUrl
            self.associatedData = data
        }
        
        init(pair: Pair) {
            self.init(environment: pair.0, baseUrl: pair.1)
        }
        
        internal mutating func storeObject(_ data: Data) {
            self.associatedData = data
        }
        
        // Hashable
        var hashValue: Int {
            return "\(environment),\(baseUrl)".hashValue
        }
        
        
        // Equatabe
        static func ==(lhs: EnvironmentDetail, rhs: EnvironmentDetail) -> Bool {
            return lhs.baseUrl == rhs.baseUrl && lhs.environment == rhs.environment
        }
    
    }
    
    
    /// Tuple type that represents an Environment.
    /// - seealso: Envoroment.asPair
    public typealias Pair = (environment: Environment, baseUrl: URL)
    
    /// The name of the API (e.g. MDQuoteService)
    public let name: String
    
    
    // Data structure to hold the environments for this Entry
    internal fileprivate(set) var environments: [EnvironmentDetail]
    
    /// The standard initializer for an Entry
    ///
    /// - Parameters:
    ///   - name: The name of the entry, this should be something like the name of your API, (e.g. "MDQuoteService")
    ///   - initialEnvironment: The initial environment as a tuple. (e.g. acc, prod, acceptance, test, etc.) The URL should be the base URL to your service
    public init(name: String, initialEnvironment: Pair) {
        environments = [EnvironmentDetail(environment: initialEnvironment.environment, baseUrl: initialEnvironment.baseUrl)]
        self.name = name
    }
    
    /// Initializes a new Entry with a name and a list of environments and URLs.
    ///
    /// - Parameters:
    ///   - name: The name of the Entry
    ///   - environments: The list of environments and URLs. There must be at least one element in this or an assertion is raised. The first element is used as the initial current environment
    public init(name: String, environments: [Pair]) {
        precondition(environments.count > 0, "You must pass at least one environment pair.")
        var environments = environments
        self.init(name:name, initialEnvironment: environments.removeFirst())
        add(environments)
    }
    
    internal init(name: String, environments: [EnvironmentDetail]) {
        self.name = name
        self.environments = environments
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
    private func index(for env: Environment) -> Int? {
        return environments.index(where: { $0.environment == env })
    }
    /// Builds a URL by appending a path to the currently selected environment's baseURL
    ///
    /// - Parameter path: The path to append
    /// - Returns: The new URL or nil if the URL could not be formed
    public func buildURLForEnvironment(_ environment: Environment, path: String) -> URL? {
        return baseUrl(forEnvironment: environment)?.appendingPathComponent(path)
    }
    
    /// Returns the base URL for a given environment, or nil if the environment does not exist for this entry
    ///
    /// - Parameter environment: The environment name
    /// - Returns: The base URL for that environment, or nil
    public func baseUrl(forEnvironment env: Environment) -> URL? {
        guard let index = index(for: env) else {
            return nil
        }
        return environments[index].baseUrl
    }
    
    /// Returns an array of all of the current environments this manager is managing
    ///
    /// - Returns: An array of environment names.
    public func environmentNames() -> [String] {
        return environments.map({ $0.environment })
    }
    
    // TODO: rename to match a standard
    /// Returns the base API for a given environment
    public func currentBaseUrlForEnvironment(_ env: Environment) -> URL? {
        guard let found = environments.first(where: { $0.environment == env }) else {
            return nil
        }
        return found.baseUrl
    }
    
    public func additionalDataFor<T: Codable>(environment: Environment) -> T? {
        guard let data = environments.find(environment)?.associatedData else {
            return nil
        }
        let decoded: T? = DataConverter.decode(data: data)
        return decoded
    }
    
    internal mutating func store(data: Data, forEnvironment env: Environment) {
        guard var found = environments.find(env) else { return }
        found.storeObject(data)
        environments.replace(found)
    }
    
    internal mutating func store<T: Codable>(object: T, forEnvironment env: Environment) {
        guard var found = environments.find(env),
            let data = try? DataConverter.convert(object: object) else { return }
        found.storeObject(data)
        environments.replace(found)
    }
}


// MARK: - Convenience collection helpers
extension Sequence where Element == Entry.EnvironmentDetail {
    func find(_ env: Environment) -> Element? {
        return first { $0.environment == env }
    }
}

// TOOD: might be useful in common code
extension Array where Element: Equatable {
    /// In the event an element may be mutated but still be equatable with another one, this function will replace it.
    ///
    /// - Parameter element: The element to replace. It must already exist in the array
    mutating func replace(_ element: Element) {
        for (i, e) in enumerated() {
            if e == element {
                self.remove(at: i)
                self.insert(element, at: i)
                break
            }
        }
    }
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
        return environmentNames()[safe: index]
    }
    
    /// Returns the baseURL for a given index. The baseURLs are put into a sorted order using a function. The default function is ascending.
    ///
    /// - Parameters:
    ///   - index: The index to search
    ///   - function: Optional paramter to override the default sort. The default is ascending
    /// - Returns: The base URL as a URL or nil if the index was out of bounds
    public func baseUrl(forIndex index: Int) -> URL? {
        guard let environment = environmentNames()[safe: index] else {
            return nil
        }
        return baseUrl(forEnvironment: environment)
    }
}


// MARK: - Internal mutating functions
extension Entry {
    /// Adds a new environment and corresponding baseURL to this entry
    ///
    /// - Parameters:
    ///   - url: The base URL
    ///   - environment: The environment it belongs to
    internal mutating func add(url: URL, forEnvironment environment:String) {
        environments.append(EnvironmentDetail(environment: environment, baseUrl: url))
    }
    
    /// Adds a new envvironemt and base URL to this entry
    ///
    /// - Parameter pair: The tuple representing the environment and baseUR:
    internal mutating func add(_ pair: Pair) {
        add(url: pair.baseUrl, forEnvironment: pair.environment)
    }
    
    
    // TOOD: unit test
    /// Adds an array of environment pairs to this Entry
    ///
    /// - Parameter pairs: The environments to add
    internal mutating func add(_ pairs: [Pair]) {
        pairs.forEach{ self.add($0) }
    }
    
    // TOOD: unit test
    @discardableResult
    internal mutating func removeEnvironment(_ name: String) -> Bool {
        guard let index = environments.index(where:{ $0.environment == name }) else {
            return false
        }
        environments.remove(at: index)
        return true
    }
}

// MARK: - Storage to DataStore
extension Entry {
    private static let storageEntryKey = "CustomEntryStorage"
    internal func writeToStore(_ store: DataStore) {
        var store = store
        
        
        if store[Entry.storageEntryKey] == nil {
            store[Entry.storageEntryKey] = [[String: Any]]()
        }
        
        var array = store[Entry.storageEntryKey] as! [[String: Any]]
        array.append(serialize())
        store[Entry.storageEntryKey] = array
    }
    
    // TOOD: port Entry to `Codeable` in swift 4
    private func serialize() -> [String: [[String: String]]] {
        let name = self.name
        let pairs = environments
        return [name: pairs.map { [$0.environment: $0.baseUrl.absoluteString] }]
    }
}



// MARK: - Special support for combining Sequence of `Entry` items
extension Sequence where Self.Iterator.Element == Entry {
    internal static func +(left: Self, right: Self) -> [Entry] {
        // The below logic is a bit scary at first, but basically I am doing the following.
        // Find any overlapping entries that are in both the "CustomEntryStore" store, as well as the ones added at initialization via CSV. Entry is treated as a value object, and thus such is transactional, so modifying, creating, etc. dont really matter. (its all stored underneath, either in the self.entries, created via CSV, or in the CustomEntryStore, created via user and stored as CSV strings)
        // For each in memory entry, we find the entry that also exists in the CustomStore.
        // After that, we flat map out the environments and add them to the current entry.
        // We than add that into the final list.
        
        var finalSet = [Entry]()
        left.forEach({ (entry) in
            var entry = entry
            entry.add(right.filter{ $0.name == entry.name }.flatMap{ $0.environments.map{$0.asPair} })
            finalSet.append(entry)
        })
        return finalSet
    }
}
