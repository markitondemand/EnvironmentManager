//  Copyright © 2017 Markit. All rights reserved.
//


// TOOD: move this to its own common code
import Foundation


/// The DataStore is an abstract class for storing data in different ways. It separates the "How" and the "What".
public protocol DataStore {
    
    /// Read and write values using subscript similar to Dictionary. If you are using a UserDefault store the object stores must be Plist compatibile
    ///
    /// - Parameter key: The key to store
    subscript(key: String) -> Any? { get set }
}

/// Simple class that implements the DataStore protocol using an in memory Dictionary
public class DictionaryStore: DataStore {
    private var backingDictionary: [String:Any] = [:]
    
    public subscript(key: String) -> Any? {
        get {
            return self.backingDictionary[key]
        }
        set(newValue) {
            self.backingDictionary[key] = newValue
        }
    }
}


/// Implements the DataStore protocol using a UserDefaults
public class UserDefaultsStore: DataStore {
    private var backingDefaults: UserDefaults
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.backingDefaults = defaults
    }
    
    public subscript(key: String) -> Any? {
        get {
            return self.backingDefaults.object(forKey: key)
        }
        set(newValue) {
            self.backingDefaults.set(newValue, forKey: key)
        }
    }
}


// MARK: - Factory methods
extension DataStore {
    static func userDefaultsStore(userDefaults: UserDefaults = UserDefaults.standard) -> DataStore {
        return UserDefaultsStore()
    }
    
    static func dictionaryStore() -> DataStore {
        return DictionaryStore()
    }
}
