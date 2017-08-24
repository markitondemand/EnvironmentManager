//  Copyright © 2017 Markit. All rights reserved.
//



import Foundation

// TOOD: make "DataStore" internal
/// The DataStore is an abstract class for storing data in different ways. It separates the "How" and the "What".
public protocol DataStore {
    
    /// Read and write values using subscript similar to Dictionary. If you are using a UserDefault store the object stores must be Plist compatibile
    ///
    /// - Parameter key: The key to store
    subscript(key: String) -> Any? { get set }
}

/// Simple class that implements the DataStore protocol using an in memory Dictionary
internal class DictionaryStore: DataStore {
    private var backingDictionary: [String:Any] = [:]
    
    public subscript(key: String) -> Any? {
        get {
            return backingDictionary[key]
        }
        set(newValue) {
            backingDictionary[key] = newValue
        }
    }
}


/// Implements the DataStore protocol using a UserDefaults
internal class UserDefaultsStore: DataStore {
    private var backingDefaults: UserDefaults
    init(defaults: UserDefaults = UserDefaults.standard) {
        backingDefaults = defaults
    }
    
    public subscript(key: String) -> Any? {
        get {
            return backingDefaults.object(forKey: key)
        }
        set(newValue) {
            backingDefaults.set(newValue, forKey: key)
            backingDefaults.synchronize()
        }
    }
}
