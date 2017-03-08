//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV

// MARK: - Load via a CSV file
extension Builder {
    private struct Token {
        static let Environment = "Environment"
        static let Name = "Name"
        static let BaseURL = "BaseURL"
        static let Delimiter: UnicodeScalar = "|"
    }
    
    public func add(_ csv:String) throws -> Self {
        var parsed = try CSV(string: csv, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
        while let _ = parsed.next() {
            guard let serviceName = parsed[Token.Name],
                let environment = parsed[Token.Environment],
                let baseUrlString = parsed[Token.BaseURL] else {
                    continue // possibly throw error here for invalid csv scheme
            }
            
            _ = self.add(entry: serviceName, environments: [(environment, baseUrlString)])
        }
        return self
        
    }
}

extension EnvironmentManager {
    
    
    
    //    /// Createsa a new EnvironmentManager from a CSV File. The file should use "|" as a delimiter and have the columns in the form of "Environment|Name|BaseURL|
    //    ///
    //    /// - Parameters:
    //    ///   - csv: A string representation of a CSV file.
    //    ///   - backingStore: The store to load persisted environment from (if applicable). The user defaults will be used to read and write environment information to by default
    //    public convenience init?(_ csv: String, dataStore: DataStore = UserDefaultsStore()) {
    //        var parsed: CSV
    //        do {
    //            parsed = try CSV(string: csv, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
    //        } catch let error {
    //            print("Error loading the CSV data - CSVError:\(error)")
    //            return nil
    //        }
    //        self.init(csv: parsed, dataStore: UserDefaultsStore())
    //    }
    //
    //    /// Createsa a new EnvironmentManager from a CSV File. The file should use "|" as a delimiter and have the columns in the form of "Environment|Name|BaseURL|
    //    ///
    //    /// - Parameters:
    //    ///   - csv: A string representation of a CSV file.
    //    ///   - backingStore: The store to load persisted environment from (if applicable). The user defaults will be used to read and write environment information to by default
    //
    //    public convenience init?(_ stream: InputStream, dataStore: DataStore = UserDefaultsStore()) {
    //        var parsed: CSV
    //        do {
    //            parsed = try CSV(stream: stream, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
    //        } catch let error {
    //            print("Error loading the CSV data - CSVError:\(error)")
    //            return nil
    //        }
    //        self.init(csv: parsed, dataStore: UserDefaultsStore())
    //    }
    
}
