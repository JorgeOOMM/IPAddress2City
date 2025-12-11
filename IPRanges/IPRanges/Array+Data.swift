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
/// - Returns: [T]]
///
func convertToArray<T>(from data:Data) -> [T] {
    let capacity = data.count / MemoryLayout<T>.size
    let result = [T](unsafeUninitializedCapacity: capacity) { pointer, copied_count in
        let length_written = data.copyBytes(to: pointer)
        copied_count = length_written / MemoryLayout<T>.size
        assert(copied_count == capacity)
    }
    return result
}
/// convertToData
///
/// - Parameter array: [T]
/// - Returns: Data
///
func convertToData<T>(from array:[T]) -> Data {
    var p: UnsafeBufferPointer<T>? = nil
    array.withUnsafeBufferPointer { p = $0 }
    guard p != nil else {
        return Data()
    }
    return Data(buffer: p!)
}

//func writeBytesFrom<T>(array: [T], toFile url: URL) throws -> Bool {
//    try withUnsafePointer(to: array) { pointer in
//        let data = Data(bytes: pointer, count: array.count * MemoryLayout<T>.stride)
//        try data.write(to: url, options: .atomic)
//    }
//    return true
//}

 func arrayToFile<T>(array: [T], toFile url: URL, compress: Bool = true) throws {
     let data = convertToData(from: array)
     if compress {
         let result = Compressor.compress(content: data)
         try result?.write(to: url, options: .atomic)
     } else {
         try data.write(to: url, options: .atomic)
     }
 }

 func fileToArray<T>(file url: URL, compress: Bool = true) throws -> [T] {
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

 // Array of Strings to file separated by newLine

 func arrayToFileString(array: [String], toFile url: URL, compress: Bool = true) throws {
     let string = array.joined(separator: "\n")
     guard let data = string.data(using: .ascii) else {
         return
     }
     if compress{
         let result = Compressor.compress(content: data)
         try result?.write(to: url, options: .atomic)
     } else {
         try data.write(to: url, options: .atomic)
     }
 }

 // Array of Substring from file separated by newLine

 func fileStringToArray(file url: URL, compress: Bool = true) throws -> [Substring] {
     let data = try Data(contentsOf: url)
     if compress {
         guard let result = Compressor.decompress(content: data),
               let string = String(data: result, encoding: .ascii) else {
             return []
         }
         return string.split(separator:  "\n")
     } else {
         guard let string = String(data: data, encoding: .ascii) else {
             return []
         }
         return string.split(separator: "\n")
     }
 }
