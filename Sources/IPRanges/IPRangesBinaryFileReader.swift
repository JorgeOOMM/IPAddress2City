//
//  IPRangesReaderBinaryFile.swift
//  IPRanges
//
//  Created by Mac on 10/12/25.
//

import Foundation

// MARK: IPRangesBinaryFileLoader
class IPRangesBinaryFileReader: LocationProtocol {
    private var subdivs: [Substring] = []
    private var fileHandle: FileHandle = .nullDevice
    private var fileSize: UInt64 = 0
    private let sizeofRange = MemoryLayout<IPRangeIdx>.size
    
    // MARK: LoaderProtocol
    func load() -> Bool {
        do {
            let dataURL = URL.documentsDirectory
                .appendingPathComponent("IP-COUNTRY.bin")
            
            self.fileHandle = try FileHandle(forReadingFrom: dataURL)
            self.fileSize = try fileHandle.seekToEnd()
            
            let dataURLSubdivs = URL.documentsDirectory
                .appendingPathComponent("COUNTRY-SUBDIVS.bin")
            
            // The file in Document directory is already decompress
            self.subdivs = try fileStringToArray(
                from: dataURLSubdivs,
                compress: false
            )
            
        } catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    private func readRecord(index: Int) throws -> IPRangeIdx {
        precondition(self.fileHandle != .nullDevice)
        let offset = UInt64(index * sizeofRange) // Seek to the index
        try fileHandle.seek(toOffset: offset)
        let data = fileHandle.readData(ofLength: sizeofRange) // Read sizeOfRange
        precondition( data.count == sizeofRange)
        let result = data.withUnsafeBytes { buffer in
            buffer.baseAddress?.assumingMemoryBound(to: IPRangeIdx.self).pointee
        }
        guard let result = result else {
            throw CustomError.memoryError
        }
        return result
    }
    
    /// IP addess to IPRange
    ///
    /// - Parameter beIP: Big Endian 32 bits IP address
    /// - Returns: IPRange
    ///
    /// - Note [Algorithm]
    ///
    ///  Calculate the middle element index: mid = start + (end - start) / 2 .
    ///  Compare the value at middle index ( mid ) with the target value.
    ///  If arr[mid] is equal to the target value, return mid (search successful).
    ///  If arr[mid] is less than the target value, set the start to mid + 1 .
    ///
    ///
    func location(from address: UInt32) -> IPRange? {
        var lowIndex = 0
        var highIndex = Int(fileSize) / sizeofRange
        var midIndex = 0
        do {
            while lowIndex <= highIndex {
                midIndex = (Int)((lowIndex + highIndex) / 2)
                let line = try readRecord(index: midIndex)
                // let line = lines[midIndex]
                if address >= line.start && address < line.end {
                    let alpha2 = Countries.shared.indexes.key(from: UInt32(line.alpha2Idx))!
                    let subdiv = self.subdivs[Int(line.subdivIdx)].replacingOccurrences(of: "#", with: " - ")
                    return IPRange(
                        start: line.start,
                        end: line.end,
                        alpha2: alpha2,
                        subdiv: subdiv
                    )
                } else {
                    if address < line.end {
                        highIndex = midIndex - 1
                    } else {
                        lowIndex = midIndex + 1
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
