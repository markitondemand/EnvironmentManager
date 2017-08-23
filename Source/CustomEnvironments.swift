//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation



/// CustomEntryStore is a class that is meant to be used when adding, creating, or removing custom entries that should persist beyond the lifetime of the EnvironmentManager
/// These are stored as CSV strings in a given `DataStore`
class CustomEntryStore {
    private static let CustomEnvironmentsKey = "com.markit.environmentManager.CustomEnvironmentsKey"
    var store: DataStore
    
    fileprivate var entryDictionary: [String: String] {
        get {
            return store[CustomEntryStore.CustomEnvironmentsKey] as? [String: String] ?? [:]
        }
        set (value) {
            store[CustomEntryStore.CustomEnvironmentsKey] = value
        }
    }
    
    
    /// Returns a list of all Entry objects currently stored in this CustomEntryStore
    var allEntries: [Entry] {
        let customEntries = entryDictionary
        return customEntries.map{ return Entry(csv: $1 )}.flatMap{$0}
    }
    
    
    /// Standard initializer.
    ///
    /// - Parameter store: The DataStore to use for reading and writing entries from / to
    init(_ store: DataStore) {
        self.store = store
    }
    
    
    /// Adds a new custom entry to the current DataStore
    ///
    /// - Parameter entry: The entry to add
    func addCustomEntry(_ entry: Entry) {
        self[entry.name] = entry
    }
    
    
    /// Adds an array of environments to a given entry
    ///
    /// - Parameters:
    ///   - environments: The environments to add
    ///   - name: The name of the entry to add to. If the entry does not exist, it will be created
    func addEnvironments(_ environments: [Entry.Pair], forEntry name: String) {
        let entryToUpdate: Entry
        if var entry = self[name] {
            environments.forEach {
                entry.add($0)
            }
            entryToUpdate = entry
        }
        else {
            entryToUpdate = Entry(name: name, environments: environments)
        }
        
        self[name] = entryToUpdate
    }
    
    
    /// Attempts to remove a given set of environments by name from a given entry. If the environment names match what is stored, the environment will be removed
    ///
    /// - Parameters:
    ///   - environments: The environments to remove
    ///   - name: The name of the entry to remove from
    func removeEnvironments(_ environments: [String], forEntryNamed name: String) {
        guard var entry = self[name] else {
            return
        }
        
        environments.forEach {
            entry.removeEnvironment($0)
        }
        
        self[name] = entry
    }
    
    
    /// Attempts to remove a given set of environments from a given entry.
    ///
    /// - Parameters:
    ///   - environments: The environments to remove
    ///   - name: The name of the entry to remove from
    func removeEnvironments(_ environments: [Entry.Environment], forEntryNamed name: String) {
        self.removeEnvironments(environments.map{$0.environment}, forEntryNamed: name)
    }
    
    
    /// Attempts to remove a custom entry
    ///
    /// - Parameter name: The name of the entry to remove
    /// - Returns: True if an entry was removed, otherwise false
    @discardableResult func removeCustomEntry(_ name: String) -> Bool {
        guard let result = self[name] else {
            return false
        }
        
        self[result.name] = nil
        return true
    }
    
    /// Attempts to remove a custom entry
    ///
    /// - Parameter entry: The entry to try and remove
    /// - Returns: True if an entry was removed, otherwise false
    @discardableResult func removeCustomEntry(_ entry: Entry) -> Bool {
        return removeCustomEntry(entry.name)
    }
    

}

// MARK: - Subscript
extension CustomEntryStore {
    subscript(name: String) -> Entry? {
        get {
            guard let string = entryDictionary[name] else {
                return nil
            }
            return Entry(csv: string)
        }
        set(newEntry) {
            var dictionary = self.entryDictionary
            dictionary[name] = newEntry?.asCSV
            self.entryDictionary = dictionary
        }
    }
    
}

// MARK: - Addition operator
extension CustomEntryStore {
    // TOOD: determine if we should do this and add a unit test
    func add(left: CustomEntryStore, right: Entry) -> CustomEntryStore {
        left.addCustomEntry(right)
        return self
    }
}

// MARK: - conveinece for Entry
extension CustomEntryStore {
    internal func add(pair: Entry.Pair, to entryName: String) {
        guard var entry = self[entryName] else {
            self[entryName] = Entry(name: entryName, initialEnvironment: pair)
            return
        }
        entry.add(pair)
        self[entryName] = entry
    }
}
