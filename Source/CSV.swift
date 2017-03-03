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
//    func
    convenience init?(csv: String, dataStore: DataStore = UserDefaultsStore()) {
        var parsed: CSV
        do {
            parsed = try CSV(string: csv, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
        } catch let error {
            print("Error loading the CSV data - CSVError:\(error)")
            return nil
        }
        self.init(csv: parsed, dataStore: UserDefaultsStore())
        
    }
    
    internal convenience init?(csv: CSV, dataStore: DataStore) {
        self.init(backingStore: dataStore)
        var csv = csv
        
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
