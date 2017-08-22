//  Copyright © 2017 Markit. All rights reserved.
//


// TOOD: move this to its own common code
import Foundation

public protocol Stringable {
    var stringValue: String { get }
}

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
            print("key:\(key), value:\(backingDictionary[key])")
            return backingDictionary[key]
        }
        set(newValue) {
            backingDictionary[key] = newValue
        }
    }
}


/// Implements the DataStore protocol using a UserDefaults
public class UserDefaultsStore: DataStore {
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
