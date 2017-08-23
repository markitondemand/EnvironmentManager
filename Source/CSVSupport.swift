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
    @discardableResult public func add(_ csv: String) throws -> Self {
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
    @discardableResult public func add(_ csvStream: InputStream) throws -> Self {
        do {
            let parsed = try CSV(stream: csvStream, hasHeaderRow: true, trimFields: true, delimiter: Token.Delimiter)
            return add(parsed)
        } catch let csvError as CSVError {
            throw BuildError.CSVParsingError(error: csvError)
        }
    }
    
    // Helper method that coalesces the above two methods
    private func add(_ csv:CSV) -> Self {
        while let _ = csv.next() {
            guard let serviceName = csv[Token.Name],
                let environment = csv[Token.Environment],
                let baseUrlString = csv[Token.BaseURL] else {
                    continue // possibly throw error here for invalid csv scheme
            }
            
            self.add(entry: serviceName, environments: [(environment, baseUrlString)])
        }
        return self
    }
}



// MARK: - Entry TO and FROM CSV
extension Entry {
    
    /// Converts the current Entry to a valid CSV string
    ///
    /// An entry with three environments will generate a CSV string with three line items in the following form, appending new lines if necessary `[Service]|[Name]|[URL]`
    /// Example Usage:
    /// `let csvString = entry.asCSV`
    public var asCSV: String {
        get {
            let stream = OutputStream(toMemory: ())
            let csv = try! CSVWriter(stream: stream, delimiter: "|", newline: .lf)
            
            // Write a row
            for pair in self.environments {
                try! csv.write(row: [self.name, pair.environment, pair.baseUrl.absoluteString])
                csv.beginNewRow()
            }
            
            
            csv.stream.close()
            
            // Get a String
            let csvData = stream.property(forKey: .dataWrittenToMemoryStreamKey) as! NSData
            let csvString = String(data: Data(referencing: csvData), encoding: .utf8)!
            return csvString
        }
    }
    
    /// This initializer expects a CSV string formatted in the following way
    /// `[ServiceName]|[EnvironmentName]|[URL]`
    /// Alternatively, if an Entry needs more than one environment a CSV string can be passed, appending additional CSV lines. As long as the [ServiceName] matches, this will create an Entry. If the [ServiceName] mismatches than nil will be returned. Essentially, follow the prescribed format.
    /// 
    /// Example Usage:
    /// `Service1|acc|http://acc.api.service.com\n
    ///  Serivce1|prod|http://prod.api.service.com`
    ///
    /// Invalid usage that will result in nil:
    /// `Service1|acc|http://acc.api.service.com\n
    ///  OtherService|prod|http://prod.api.service.com`
    init?(csv: String) {
        guard let stringData = csv.data(using: .utf8) else {
            return nil
        }
        let stream = InputStream(data: stringData)
        guard let reader = try? CSVReader(stream: stream, hasHeaderRow: false, trimFields: false, delimiter: "|", whitespaces: CharacterSet.whitespaces ) else {
            return nil
        }
        let iterator = reader.makeIterator()
        var name: String? = nil
        var environments: [(String, URL)] = []
        
        for element in iterator {
            if name == nil {
                name = element[safe: 0]
            }
            
            // Check if we are passing  correct CSV for a single entry. If for some reason additional lines contain a different service name return nil. This is probably unexpected behavior
            guard name == element[safe: 0] else {
                return nil
            }
            
            guard let environment = element[safe: 1],
                let urlString = element[safe: 2],
                let url = URL(string: urlString) else {
                    continue
            }
            
            environments.append((environment, url))
        }
        
        guard name != nil,
            environments.count > 0 else {
                return nil
        }
        // TOOD: dont pass userdefault store here
        self.init(name: name!, environments: environments)
    }
}
