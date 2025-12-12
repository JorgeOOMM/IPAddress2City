//
//  IPRangesTextFileLineLoader.swift
//  IPRanges
//
//  Created by Mac on 10/12/25.
//

import Foundation

// MARK: IPRangesTextFileLineLoader
class IPRangesTextFileLineLoader: LoaderProtocol, LocationProtocol {
    internal var lines: [IPRange] = []
    /// Load the file to process
    ///
    /// - Returns: Bool
    /// - Parameter url: File URL to process
    ///
    func load(from url: URL) -> Bool {
        guard let lineReader = LineReader(from: url.path()) else {
            print("Unable open file \(url).")
            return false
        }
        self.lines = ranges(reader: lineReader)
        return true
    }

    func location(from address: UInt32) -> IPRange? {
        var lowIndex = 0
        var highIndex = lines.count
        var midIndex = 0
        while lowIndex <= highIndex {
            midIndex = (Int)((lowIndex + highIndex)/2)
            let line = lines[midIndex]
            if address >= line.start && address < line.end {
                return line
            } else {
                if address < line.end {
                    highIndex = midIndex - 1
                } else {
                    lowIndex = midIndex + 1
                }
            }
        }
        return nil
    }
    
    private func ranges(reader: LineReader) -> [IPRange] {
        var ipRanges: [IPRange] = [IPRange]()
        for line in reader {
            let item  = line.components( separatedBy: "\",").map{$0.replacingOccurrences(of: "\"", with: "")}
            let start = UInt32(item[0])
            let end   = UInt32(item[1])
            let isoA2 = item[2]
            //let isoA3 = item[3]
            let place = item[4]
            let range = IPRange(start: start!,
                                  end: end!,
                                  alpha2: isoA2,
                                  place: place)
            ipRanges.append(range)
        }
        return ipRanges
    }
}
