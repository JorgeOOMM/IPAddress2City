//
//  Array+Data.swift
//  IPRanges
//
//  Created by Mac on 9/12/25.
//
import Foundation

/// convertToArray
///
/// - Parameter data: Data
/// - Returns: [T]
///
func convertToArray<T>(from data: Data) -> [T] {
    let capacity = data.count / MemoryLayout<T>.size
    let result = [T](unsafeUninitializedCapacity: capacity) { pointer, copiedCount in
        let lengthWritten = data.copyBytes(to: pointer)
        copiedCount = lengthWritten / MemoryLayout<T>.size
        assert(copiedCount == capacity)
    }
    return result
}
/// convertToData
///
/// - Parameter array: [T]
/// - Returns: Data
///
func convertToData<T>(from array: [T]) -> Data {
    var arrayPointer: UnsafeBufferPointer<T>?
    array.withUnsafeBufferPointer { arrayPointer = $0 }
    guard let arrayPointer = arrayPointer else {
        return Data()
    }
    return Data(buffer: arrayPointer)
}

// func writeBytesFrom<T>(array: [T], toFile url: URL) throws -> Bool {
//    try withUnsafePointer(to: array) { pointer in
//        let data = Data(bytes: pointer, count: array.count * MemoryLayout<T>.stride)
//        try data.write(to: url, options: .atomic)
//    }
//    return true
// }

///  Array  to file Data
///
///  - Note
///   - The array cant contains references to objects; like String...etc
///
///  - Parameters:
///   - array: [T]]
///   - url: URL
///   - compress: Bool
///  - Throws: description
///
func arrayToFile<T>(array: [T], to url: URL, compress: Bool = true) throws {
    let data = convertToData(from: array)
    if compress {
        let result = Compressor.compress(content: data)
        try result?.write(to: url, options: .atomic)
    } else {
        try data.write(to: url, options: .atomic)
    }
}

///  File data to Array
///
/// - Parameters:
///   - url: URL
///   - compress: Bool
///
/// - Throws: description
/// - Returns: [T]
///
func fileToArray<T>(from url: URL, compress: Bool = true) throws -> [T] {
    let data = try Data(contentsOf: url)
    if compress {
        guard let result = Compressor.decompress(content: data) else {
            return []
        }
        return convertToArray(from: result)
    } else {
        return convertToArray(from: data)
    }
}

/// Array of Strings to file separated by newLine
///
/// - Parameters:
///   - array: [String]
///   - url: URL
///   - compress: Bool
///
/// - Throws: description
///
func arrayToFileString(array: [String], to url: URL, compress: Bool = true) throws {
    let string = array.joined(separator: "\n")
    guard let data = string.data(using: .ascii) else {
        return
    }
    if compress {
        let result = Compressor.compress(content: data)
        try result?.write(to: url, options: .atomic)
    } else {
        try data.write(to: url, options: .atomic)
    }
}
///  Array of Substring from file separated by newLine
///
/// - Parameters:
///   - url: URL
///   - compress: Bool
///
/// - Throws: description
/// - Returns: [Substring]
///
func fileStringToArray(from url: URL, compress: Bool = true) throws -> [Substring] {
    let data = try Data(contentsOf: url)
    if compress {
        guard let result = Compressor.decompress(content: data),
              let string = String(data: result, encoding: .ascii) else {
            return []
        }
        return string.split(separator: "\n")
    } else {
        guard let string = String(data: data, encoding: .ascii) else {
            return []
        }
        return string.split(separator: "\n")
    }
}
