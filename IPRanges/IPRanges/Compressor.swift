//
//  Compressor.swift
//
//  Created by Mac on 18/9/24.
//
import Foundation

class Compressor {
    ///  Write file to Documents
    ///
    /// - Parameters:
    ///   - fileName: The file name to write to
    ///   - data:  Data
    /// - Returns: Bool
    ///
    static func writeToDocuments( fileName: String, data: Data) -> Bool {
        let url = URL.documentsDirectory.appending(path: fileName)
        return write(to: url, data: data)
    }
    ///  Write file to URL
    ///
    /// - Parameters:
    ///   - url: The file URL to write to
    ///   - data:  Data
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
    ///  Read file from Documents
    ///
    /// - Parameter fileName: The file name to read from
    /// - Returns: Data?
    ///
    static func readFromDocuments( fileName: String) -> Data? {
        let url = URL.documentsDirectory.appending(path: fileName)
        return read(from: url)
    }
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
    /// Decompress from file in Documents
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func decompressFromDocuments(name: String,
                                        algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        let url = URL.documentsDirectory.appending(path: name)
        return decompress(from: url, algorithm: algorithm)
    }
    
    /// Decompress from file in Resources
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - ext: <#ext description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func decompressFromResources(name: String,
                                        ext: String = "",
                                        algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "")  else {
            print("Unable to locate \(name).\(ext) at Resources.")
            return nil
        }
        return decompress(from: url, algorithm: algorithm)
    }
    
    /// Decompress file from Resources
    ///
    /// - Parameters:
    ///   - name: String
    ///   - ext: String
    ///   - to: URL
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Bool
    ///
    static func decompressFromResources(name: String,
                                        ext: String = "",
                                        to: URL,
                                        algorithm: NSData.CompressionAlgorithm = .lzma) -> Bool {
        
        if let data = Compressor.decompressFromResources(name: name, ext: ext, algorithm: algorithm) {
            do {
                try data.write(to: to, options: .atomic)
                return true
            } catch {
                print("Unable to write Data from \(name).\(ext) to \(to). Error: \(error.localizedDescription)")
            }
        }
        return false
    }
    
    /// Decompress file from URL
    ///
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func decompress(from url: URL,
                           algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        do {
            let content = try Data(contentsOf: url)
            return decompress(content: content, algorithm: algorithm)
        } catch {
            print("Unable to decompress Data from \(url). Error: \(error.localizedDescription)")
        }
        return nil
    }
    /// Decompress file from URL to URL
    /// - Parameters:
    ///   - url: From URL
    ///   - to: To URL
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Bool
    static func decompressTo(from url: URL, to: URL, algorithm: NSData.CompressionAlgorithm = .lzma) -> Bool {
        do {
            let content = try Data(contentsOf: url)
            if let result = decompress(content: content, algorithm: algorithm) {
                return Compressor.write(to: to, data: result)
            }
        } catch {
            print("Unable to decompress Data from \(url) to \(to). Error: \(error.localizedDescription)")
        }
        return false
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - content: <#content description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func decompress(content: Data, algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        do {
            let compressedData = try (content as NSData).decompressed(using: algorithm)
            return compressedData as Data
        } catch {
            print("Unable to decompress Data. Error: \(error)")
        }
        return nil
    }
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - ext: <#ext description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func compressFromResources(name: String, ext: String = "", algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        guard let path = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "")  else {
            print("Unable to locate \(name).\(ext) at Resources.")
            return nil
        }
        return compress(from: path, algorithm: algorithm)
    }
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func compress(from url: URL, algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        do {
            let content = try Data(contentsOf: url)
            return compress(content: content, algorithm: algorithm)
        } catch {
            print("Unable to compress Data from \(url). Error: \(error.localizedDescription)")
        }
        return nil
    }
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func compressFromDocuments(name: String, algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        let url = URL.documentsDirectory.appending(path: name)
        return compress(from: url, algorithm: algorithm)
    }
    /// <#Description#>
    /// - Parameters:
    ///   - content: <#content description#>
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func compress(content: Data, algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        do {
            let compressedData = try (content as NSData).compressed(using: algorithm)
            return compressedData as Data
        } catch {
            print("Unable to compress Data. Error: \(error.localizedDescription)")
        }
        return nil
    }
}
