//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV
import MD_Extensions


/// Use an instance of the Builder to create your EnvironmentManager. This provides reasonable defaults, failsafes, and error handling in the event something is misconfigured on your end. You use this class by chaining calls to a single Builder() and ultimately end with a "build()" call.
/// ```
/// Builder()
/// .setDataStore(store: DictionaryStore())
/// .add(myCSVStringData)
/// .build()
/// ```
/// This also supports managing production environments. When you are ready to ship a production app you can configure the Builder to production mode and tell it what type of Environments are production. This will than discard all other environments. If you are missing anything in your map an error will be raised.
/// ```
/// Builder()
/// // assume entries were added here
/// .productionEnvironments(map: ["Service1":"Prod", "Service2":"Prod"])
/// .production() // This signifies we are doing a production build. Optionally, pass your own block in to return true or false, you can than inject a #ifdef based off of your configuration
/// .build()
public class Builder {
    internal var dataStore: DataStore = UserDefaultsStore()
    internal var entries: [String:[(String, String)]] = [:]
    internal var productionEnvironmentMap: [String:String] = [:]
    internal var productionEnabled: () -> Bool = { return false }
    internal var sortOption: SortType = .added
    
    
    /// List of erors that may occur when building the EnvironmentManager
    ///
    /// - NoProductionEnvironmentSet: A service does not have a production environment set. The service at fault is passed back
    /// - EnvironmentCouldNotBeFound: A service has a non existant environemnt set. The service at fault and the environment are passed back
    /// - UnableToConstructBaseUrl: A base URL instance could not be constructed. The service at fault and the urlString are passed back
    /// - CSVParsingError: An error occurred parsing a CSV file. the error details from the CSV parser are passed back
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
    @discardableResult public func add(entry name: String, environments:[(String, String)]) -> Self {
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
    @discardableResult public func setDataStore(store: DataStore) -> Self {
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
    @discardableResult public func productionEnvironments(map: [String: String]) -> Self {
        productionEnvironmentMap += map
        return self
    }
    
    /// Sets the builder to production mode. This will cause it to use the associated productionEnvironmentMap you provide to only set up the environments for production. (I.e. Only the production environments will end up in the produced EnvironmentManager).
    /// Pass your own block in to externally change if this should build in production
    /// Example
    /// ```
    /// Builder().production({
    /// #ifdef RELEASE
    ///     return true
    /// #else
    ///     return false
    /// #endif
    /// }
    /// ```
    ///
    /// - Parameter expression: The block that will be evaluated to determine if the builder should build for production or not. The default for this will return true
    /// - Returns: The current builder
    @discardableResult public func production(expression: @escaping() -> Bool = { return true }) -> Self {
        self.productionEnabled = expression
        return self
    }
}


// MARK: - Sorting
extension Builder {
    
    /// Represents a way that entries and environments are sorted when using any index: methods, or getting lists of things. Right now only one sort type is supported. To add additional sorting options there will need to be refactoring done to the code base.
    ///
    /// - added: Sorted by the order the item was added.
    public enum SortType {
        case added
    }
    public func sortBy(_ type: SortType) -> Self {
        sortOption = type
        
        return self
    }
}


// MARK: - Builder build function
extension Builder {
    
    /// Builds a new EnvironentManager based on the currently configured Builder
    ///
    /// - Returns: Returns a new EnvironmentManager, or throws an error in the event an error occurred
    /// - Throws: Throws a BuildError in the event an error occurred, please see BuildError for details of the error
    public func build() throws -> EnvironmentManager {
        var localEntries = self.entries
        if productionEnabled() {
            for (service, environments) in self.entries {
                guard let prodEnvToPick = productionEnvironmentMap[service] else {
                    // Throw no prod API set for service error
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
