//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV


class Builder {
//    var product: EnvironmentManager?
    var dataStore: DataStore = UserDefaultsStore()
    var entries: [Entry] = []
    
    public enum BuildError: Error {
        case NotStartedBuilding
        case NoProductionEnvironmentSet(name: String)
        case UnderlyingCSVError(error: CSVError)
    }
    
    
    init() {
        
    }
    
    func addEntries(from csv:String) -> Self {
        return self
        
    }
    
    func add(entry: Entry) -> Self {
        entries.append(entry)
        return self
    }
    
    func add(entries: [Entry]) -> Self {
        return self
    }
    
    func setDataStore(store: DataStore) -> Self {
        dataStore = store
        return self
    }
    
    func build() throws -> EnvironmentManager {
//        guard let product = self.product else {
//            throw BuildError.NotStartedBuilding
//        }
        let product = EnvironmentManager(initialEntries:entries, backingStore: dataStore)
        
        return product
    }
    
    
}
