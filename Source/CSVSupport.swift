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
    
    
    /// Attempts to add a string of CSV data to the builder
    ///
    /// This should be in the following form
    /// ```
    /// Name|Environment|BaseURL
    /// ApiName|Env|http://base.url.com
    /// ```
    ///
    /// - Parameter csv: The csv string
    /// - Returns: The current builder
    /// - Throws: If there is a parse error, the error will be wrapped in BuildError.CSVParsingError()
    public func add(_ csv: String) throws -> Self {
        do {
            let parsed = try CSV(string: csv, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
            return add(parsed)
        } catch let csvError as CSVError {
            throw BuildError.CSVParsingError(error: csvError)
        }
    }
    
    
    /// Attempts to add the contents of a InputStream of a CSV file
    ///
    /// This should be in the following form
    /// ```
    /// Name|Environment|BaseURL
    /// ApiName|Env|http://base.url.com
    /// ```
    ///
    /// - Parameter csvStream: The stream to use
    /// - Returns: The current builder
    /// - Throws: If there is a parse error, the error will be wrapped in BuildError.CSVParsingError()
    public func add(_ csvStream: InputStream) throws -> Self {
        do {
            let parsed = try CSV(stream: csvStream, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
            return add(parsed)
        } catch let csvError as CSVError {
            throw BuildError.CSVParsingError(error: csvError)
        }
    }
    
    // Helper method that coalesces the above two methods
    private func add(_ csv:CSV) -> Self {
        var csv = csv
        while let _ = csv.next() {
            guard let serviceName = csv[Token.Name],
                let environment = csv[Token.Environment],
                let baseUrlString = csv[Token.BaseURL] else {
                    continue // possibly throw error here for invalid csv scheme
            }
            
            _ = self.add(entry: serviceName, environments: [(environment, baseUrlString)])
        }
        return self
    }
}
