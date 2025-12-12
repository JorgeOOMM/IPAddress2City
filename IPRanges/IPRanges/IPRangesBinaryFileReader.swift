//
//  IPRangesReaderBinaryFile.swift
//  IPRanges
//
//  Created by Mac on 10/12/25.
//

import Foundation

// MARK: IPRangesBinaryFileLoader
class IPRangesBinaryFileReader: LocationProtocol {
    private var places: [Substring]  = []
    private var fileHandle: FileHandle = .nullDevice
    private var fileSize: UInt64 = 0
    private let sizeofRange = MemoryLayout<IPRangeIndexed>.size
    
    // MARK: IPRangesLoaderProtocol
    init() {
        do {
            let dataURL = URL.documentsDirectory
                .appendingPathComponent("IP-COUNTRY.bin")
            
            self.fileHandle = try FileHandle(forReadingFrom: dataURL)
            self.fileSize = try fileHandle.seekToEnd()
            
            let dataURLPlaces = URL.documentsDirectory
                .appendingPathComponent("COUNTRY-PLACES.bin")
            
            self.places = try fileStringToArray(file:dataURLPlaces, compress: false)
        
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func readRecord(index: Int) throws -> IPRangeIndexed {
        precondition(self.fileHandle != .nullDevice)
        let offset: UInt64 = UInt64(index * sizeofRange) // Seek to the index
        try fileHandle.seek(toOffset: offset)
        // Ahora puedes leer datos desde este punto
        let data = fileHandle.readData(ofLength: sizeofRange) // Read sizeOfRange
        precondition( data.count == sizeofRange)
        let result = data.withUnsafeBytes { buffer in
          buffer.baseAddress!.assumingMemoryBound(to: IPRangeIndexed.self).pointee
        }
        return result
    }
    
    /// IP addess to IPRange
    ///
    /// - Parameter beIP: Big Endian 32 bits IP address
    /// - Returns: IPRange
    ///
    /// Algorithm
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
                midIndex = (Int)((lowIndex + highIndex)/2)
                let line = try readRecord(index: midIndex)
                //let line = lines[midIndex]
                if address >= line.start && address < line.end {
                    return IPRange(start: line.start,
                                     end: line.end,
                                     alpha2: Countries.numericISO.key(from: UInt32(line.alpha2))!,
                                     place: self.places[Int(line.placeIndex)].replacingOccurrences(of: "#", with: " - "))
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
