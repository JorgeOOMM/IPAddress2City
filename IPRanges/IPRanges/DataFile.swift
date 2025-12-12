//
//  DataFile.swift
//  IPRanges
//
//  Created by Mac on 11/12/25.
//

import Foundation

//
// Simple Data Read and write class that dont throw exceptions
//

// MARK: DataFile
class DataFile {
    ///  Read file from URL
    ///
    /// - Parameter url:The file URL to read from
    /// - Returns: Data?
    ///
    static func read( from url: URL) -> Data? {
        do {
            let content = try Data(contentsOf: url)
            return content
        } catch {
            print("Unable to read Data from \(url). Error: \(error.localizedDescription)")
        }
        return nil
    }
    ///  Write file to URL
    ///
    /// - Parameters:
    ///   - url: The file URL to write to
    ///   - data:  Data
    ///
    /// - Returns: Bool
    static func write(to url: URL, data: Data) -> Bool {
        do {
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return true
        } catch {
            print("Unable to write Data to \(url). Error: \(error.localizedDescription)")
            return false
        }
    }
    
    ///  Write file to Documents
    ///
    /// - Parameters:
    ///   - fileName: The file name to write to
    ///   - data:  Data
    ///
    /// - Returns: Bool
    static func writeToDocuments( fileName: String, data: Data) -> Bool {
        let url = URL.documentsDirectory.appending(path: fileName)
        return DataFile.write(to: url, data: data)
    }
    
    ///  Read file from Documents
    ///
    /// - Parameter fileName: The file name to read from
    ///
    /// - Returns: Data?
    static func readFromDocuments( fileName: String) -> Data? {
        let url = URL.documentsDirectory.appending(path: fileName)
        return DataFile.read(from: url)
    }
    
    ///  Read file from Resources
    ///
    /// - Parameters:
    /// - Parameter fileName:The file name to read from
    ///   - withExtension: String
    ///   - subpath: String?
    ///
    /// - Returns: Data?
    static func readFromResources(fileName: String,
                                  withExtension: String? = nil,
                                  subdirectory subpath: String? = nil) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName,
                                        withExtension: withExtension,
                                        subdirectory: subpath)  else {
            print("Unable to locate \(fileName).\(withExtension ?? "") at Bundle Resources.")
            return nil
        }
        return DataFile.read(from: url)
    }
}
