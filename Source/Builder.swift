//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV

// TOOD: Error handle CSV parsing better. Wrap the CSV.swift error with our own error
// TOOD: builder with input stream for csv parsing
// TODO: clean up access mutators for Entry and EnvironmentManager since we now use Builder
// TOOD: update example... it is probably not compiling
class Builder {
    var dataStore: DataStore = UserDefaultsStore()
    var entries: [String:[(String, String)]] = [:]
    var productionEnvironmentMap: [String:String] = [:]
    var productionEnabled: Bool = false
    
    
    /// List of erors that may occur when building the EnvironmentManager
    ///
    /// - NoProductionEnvironmentSet: A service does not have a production environment set. The service at fault is passed back
    /// - EnvironmentCouldNotBeFound: A service has a non existant environemnt set. The service at fault and the environment are passed back
    /// - UnableToConstructBaseUrl: A base URL instance could not be constructed. The service at fault and the urlString are passed back
    /// - CSVParsingError: An error occurred parsing a CSV file. the erorr details from the CSV parser are passed back
    public enum BuildError: Error {
        case NoProductionEnvironmentSet(service: String)
        case EnvironmentCouldNotBeFound(service: String, name: String)
        case UnableToConstructBaseUrl(service: String, urlString: String)
        case CSVParsingError(error: CSVError)
    }
    
    
    public init() { }
    
    
    /// Adds a new entry, or updates an existing entry (if already added) with environments
    ///
    /// - Note: The number of enviromments must be greater than zero
    /// - Parameters:
    ///   - name: The name of the entry, this would be the API or service name
    ///   - environments: The tuple of envirnments to URL Strings
    /// - Returns: The current builder
    public func add(entry name: String, environments:[(String, String)]) -> Self {
        precondition(environments.count > 0, "Must pass at least one environment")
        guard var currentEnvironments = entries[name] else {
            entries[name] = environments
            return self
        }
        currentEnvironments.append(contentsOf: environments)
        entries[name] = currentEnvironments
        return self
    }
    
    
    /// Override the default data store with your own
    ///
    /// - Parameter store: The store to use
    /// - Returns: The current builder
    public func setDataStore(store: DataStore) -> Self {
        dataStore = store
        return self
    }
}


// MARK: - Production support
extension Builder {
    
    /// Sets up the production environment mapping required for the builder to know which environments are production. This is not optional.
    /// You provide a mapping of your service name and its associated production environment. If you do not provide a complete list than .build() will throw an error
    ///
    /// - Parameter map: The map of API Entry names to envirnments.
    /// - Returns: The current builder
    public func productionEnvironments(map: [String: String]) -> Self {
        productionEnvironmentMap += map
        return self
    }
    
    
    /// Sets the builder to production mode. This will cause it to use the associated productionEnvironmentMap you provide to only set up the environments for production. (I.e. Only the production environments will  end up in the produced EnvironmentManager)
    ///
    /// - Returns: The current builder
    public func production() -> Self {
        productionEnabled = true
        return self
    }
}


// MARK: - Builder build function
extension Builder {
    
    /// Builds a new EnvironentManager based on the currently configured Builder
    ///
    /// - Returns: Returns a new EnvironmentManager, or throws an error in the event an error occurred
    /// - Throws: Throws a BuildError in the event an error occurred, please see BuildError for details of the errros
    public func build() throws -> EnvironmentManager {
        var localEntries = self.entries
        if productionEnabled {
            for (service, environments) in self.entries {
                guard let prodEnvToPick = productionEnvironmentMap[service] else {
                    // Set no prod API set for service
                    throw BuildError.NoProductionEnvironmentSet(service: service)
                }
                
                let singleEntry = environments.filter({ element -> Bool in
                    return element.0 == prodEnvToPick
                })
                
                guard singleEntry.count == 1 else {
                    throw BuildError.EnvironmentCouldNotBeFound(service: service, name: prodEnvToPick)
                }
                localEntries[service] = singleEntry
            }
        }
        
        let product = EnvironmentManager(backingStore: dataStore)
        for (name, environments) in localEntries {
            let environmentPair = try environments.map({ (environment, urlString) -> (String, URL) in
                guard let url = URL(string: urlString) else {
                    throw BuildError.UnableToConstructBaseUrl(service: name, urlString: urlString)
                }
                return (environment, url)
            })
            product.add(apiName: name, environmentUrls:environmentPair)
        }
        return product
    }
}

/// += operator for Dictionary. This takes the elements of the dictinary on the right and adds them to the elements of the dictionary on the left. Items on the left will be overwritten in the event of a key collision
///
/// - Parameters:
///   - left: The dictionary to add elements to
///   - right: The dictionary that will have its elements added from
func +=<K, V> (left: inout [K : V], right: [K : V]) {
    for (k, v) in right {
        left[k] = v
    }
}
