//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV


class Builder {
    var dataStore: DataStore = UserDefaultsStore()
    var entries: [String:[(String, String)]] = [:]
    var productionEnvironmentMap: [String:String] = [:]
    var productionEnabled: Bool = false
    
    public enum BuildError: Error {
        case NotStartedBuilding
        case NoProductionEnvironmentSet(name: String)
        case UnderlyingCSVError(error: CSVError)
    }
    
    
    public init() {
        
    }
    
    public func add(_ csv:String) -> Self {
        return self
        
    }
    
    
    public func add(entry name: String, environments:[(String, String)]) -> Self {
        entries[name] = environments
        return self
    }
    
    
    public func add(_ entries: [String:[(String, String)]]) -> Self {
        self.entries += entries
        return self
    }
    
    public func setDataStore(store: DataStore) -> Self {
        dataStore = store
        return self
    }
    
    public func build() throws -> EnvironmentManager {
        var localEntries = self.entries
        if productionEnabled {
            for (service, environments) in self.entries {
                let singleEntry = try environments.filter({ element -> Bool in
                    guard let prodEnvToPick = productionEnvironmentMap[service] else {
                        // Set no prod API set for service
                        throw NSError(domain: "", code: 1, userInfo: nil)
                    }
                    
                    return element.0 == prodEnvToPick
                })
                if singleEntry.count != 1 {
                    // throw Prod API Not defined
                    throw NSError(domain: "", code: 1, userInfo: nil)
                }
                localEntries[service] = singleEntry
            }
        }
        let product = EnvironmentManager(backingStore: dataStore)
        for (name, environments) in localEntries {
             let environmentPair = try environments.map({ (environment, urlString) -> (String, URL) in
                guard let url = URL(string: urlString) else {
                    //TODO: URL Creation Error
                    throw NSError(domain: "BuilderError", code: 1, userInfo: nil)
                }
                return (environment, url)
            })
            product.add(apiName: name, environmentUrls:environmentPair)
        }
        return product
    }
}


// MARK: - Production support
extension Builder {
    public func productionEnvironments(map: [String: String]) -> Self {
        productionEnvironmentMap += map
        return self
    }
    
    public func production() -> Self {
        productionEnabled = true
        return self
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
