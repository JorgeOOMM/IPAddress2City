//
//  Compressor.swift
//
//  Created by Mac on 18/9/24.
//
import Foundation

// Core functionality
class Compressor {
    
    /// Compress Data using `algorithm`
    ///
    /// - Parameters:
    ///   - content: Data to compress
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func compress(content: Data, algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        do {
            let compressedData = try (content as NSData).compressed(using: algorithm)
            return compressedData as Data
        } catch {
            print("Unable to compress Data using `\(algorithm)`. Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// Decompress data using `algorithm`
    ///
    /// - Parameters:
    ///   - content: Data to decompress
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func decompress(content: Data, algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        do {
            let compressedData = try (content as NSData).decompressed(using: algorithm)
            return compressedData as Data
        } catch {
            print("Unable to decompress `\(algorithm)` Data. Error: \(error.localizedDescription)")
        }
        return nil
    }
}

// Compress and decompress from URL
extension Compressor {
    
    /// Compress file from URL  using `algorithm`
    ///
    /// - Parameters:
    ///   - url: From URL
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func compress(from url: URL,
                         algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        if let content = DataFile.read(from: url) {
            return compress(content: content, algorithm: algorithm)
        }
        return nil
    }
    
    /// Compress file from URL to URL  using `algorithm`
    ///
    /// - Parameters:
    ///   - url: From URL
    ///   - to: To URL
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Bool
    static func compress(from url: URL,
                         to: URL,
                         algorithm: NSData.CompressionAlgorithm = .lzma) -> Bool {
        if let content = DataFile.read(from: url) {
            if let result = compress(content: content, algorithm: algorithm) {
                return DataFile.write(to: to, data: result)
            }
        }
        return false
    }
    
    /// Decompress file from URL
    ///
    /// - Parameters:
    ///   - url: From URL
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func decompress(from url: URL,
                           algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        if let content = DataFile.read(from: url) {
            return decompress(content: content, algorithm: algorithm)
        }
        return nil
    }
    /// Decompress file from URL to URL
    ///
    /// - Parameters:
    ///   - url: From URL
    ///   - to: To URL
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Bool
    static func decompress(from url: URL,
                           to: URL,
                           algorithm: NSData.CompressionAlgorithm = .lzma) -> Bool {
        if let content = DataFile.read(from: url) {
            if let result = decompress(content: content, algorithm: algorithm) {
                return DataFile.write(to: to, data: result)
            }
        }
        return false
    }
}

// Documents
extension Compressor {
    
    /// Decompress from file in Documents  using `algorithm`
    ///
    /// - Parameters:
    ///   - fileName: File name
    ///   - algorithm: NSData.CompressionAlgorithm
    /// - Returns: Data?
    static func decompressFromDocuments(fileName: String,
                                        algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        if let content = DataFile.readFromDocuments(fileName: fileName) {
            return decompress(content: content, algorithm: algorithm)
        }
        return nil
    }
    
    /// Compress file from Documents
    ///
    /// - Parameters:
    ///   - fileName: File name
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func compressFromDocuments(fileName: String,
                                      algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        if let content = DataFile.readFromDocuments(fileName: fileName) {
            return compress(content: content, algorithm: algorithm)
        }
        return nil
    }
}

// Resources
extension Compressor {
    
    /// Decompress from file in Resources
    ///
    /// - Parameters:
    ///   - fileName: File name
    ///   - withExtension : File extension
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func decompressFromResources(fileName: String,
                                        withExtension: String? = nil,
                                        subdirectory subpath: String? = nil,
                                        algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        if let content = DataFile.readFromResources(fileName: fileName,
                                                    withExtension: withExtension,
                                                    subdirectory: subpath) {
            return decompress(content: content, algorithm: algorithm)
        }
        return nil
    }
    
    /// Decompress file from Bunde Resources
    ///
    /// - Parameters:
    ///   - name: File name
    ///   - withExtension : File extension
    ///   - to: URL
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Bool
    ///
    static func decompressFromResources(fileName: String,
                                        withExtension: String? = nil,
                                        subdirectory subpath: String? = nil,
                                        to: URL,
                                        algorithm: NSData.CompressionAlgorithm = .lzma) -> Bool {
        if let data = Compressor.decompressFromResources(fileName: fileName,
                                                         withExtension: withExtension,
                                                         subdirectory: subpath,
                                                         algorithm: algorithm) {
           return DataFile.write(to: to, data: data)
        }
        return false
    }
    
   
    /// Compress file from Bunde Resources  using `algorithm`
    ///
    /// - Parameters:
    ///   - fileName: File name
    ///   - withExtension : File extension
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Data?
    static func compressFromResources(fileName: String,
                                      withExtension: String? = nil,
                                      subdirectory subpath: String? = nil,
                                      algorithm: NSData.CompressionAlgorithm = .lzma) -> Data? {
        if let content = DataFile.readFromResources(fileName: fileName,
                                                    withExtension: withExtension,
                                                    subdirectory: subpath) {
            return compress(content: content, algorithm: algorithm)
        }
        return nil
    }
    
    /// Decompress file from Bunde Resources
    ///
    /// - Parameters:
    ///   - name: File name
    ///   - withExtension : File extension
    ///   - to: URL
    ///   - algorithm: NSData.CompressionAlgorithm
    ///
    /// - Returns: Bool
    ///
    static func compressFromResources(fileName: String,
                                      withExtension: String? = nil,
                                      subdirectory subpath: String? = nil,
                                      to: URL,
                                      algorithm: NSData.CompressionAlgorithm = .lzma) -> Bool {
        if let data = Compressor.compressFromResources(fileName: fileName,
                                                         withExtension: withExtension,
                                                         subdirectory: subpath,
                                                         algorithm: algorithm) {
           return DataFile.write(to: to, data: data)
        }
        return false
    }
}
