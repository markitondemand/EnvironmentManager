//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation
import CSV

// MARK: - Load via a CSV file
extension EnvironmentManager {
    fileprivate struct Token {
        static let Environment = "Environment"
        static let Name = "Name"
        static let BaseURL = "BaseURL"
        static let Delimiter: UnicodeScalar = "|"
    }

    
    /// Createsa a new EnvironmentManager from a CSV File. The file should use "|" as a delimiter and have the columns in the form of "Environment|Name|BaseURL|
    ///
    /// - Parameters:
    ///   - csv: A string representation of a CSV file.
    ///   - backingStore: The store to load persisted environment from (if applicable). The user defaults will be used to read and write environment information to by default
    public convenience init?(_ csv: String, dataStore: DataStore = UserDefaultsStore()) {
        var parsed: CSV
        do {
            parsed = try CSV(string: csv, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
        } catch let error {
            print("Error loading the CSV data - CSVError:\(error)")
            return nil
        }
        self.init(csv: parsed, dataStore: UserDefaultsStore())
    }
    
    /// Createsa a new EnvironmentManager from a CSV File. The file should use "|" as a delimiter and have the columns in the form of "Environment|Name|BaseURL|
    ///
    /// - Parameters:
    ///   - csv: A string representation of a CSV file.
    ///   - backingStore: The store to load persisted environment from (if applicable). The user defaults will be used to read and write environment information to by default

    public convenience init?(_ stream: InputStream, dataStore: DataStore = UserDefaultsStore()) {
        var parsed: CSV
        do {
            parsed = try CSV(stream: stream, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
        } catch let error {
            print("Error loading the CSV data - CSVError:\(error)")
            return nil
        }
        self.init(csv: parsed, dataStore: UserDefaultsStore())
    }
    
    // MARK: - Helper initializer that  coalesces the above two constructors
    internal convenience init?(csv: CSV, dataStore: DataStore) {
        self.init(backingStore: dataStore)
        var csv = csv
        
        // TODO: We "might" want to crash if we fail to read portions of the CSV file, i.e. file is not the expected scheme, or a URL cant be made properly from the baseURL
        while let _ = csv.next() {
            guard let serviceName = csv[Token.Name],
                let environment = csv[Token.Environment],
                let baseURLString = csv[Token.BaseURL] else {
                    continue
            }
            guard let baseURL = URL(string: baseURLString) else {
                continue
            }
            
            self.add(apiName: serviceName, environmentUrls: [(environment, baseURL)])
        }
    }
}
