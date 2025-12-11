//
//  IPv4RangesFileLineReader.swift
//  IPRanges
//
//  Created by Mac on 10/12/25.
//

import Foundation

// MARK: IPv4RangesTextFileLineLoader
class IPRangesTextFileLineLoader : IPRangesLoaderProtocol {
    internal var lines: [IPRange] = []
    func load() -> Bool {
        let path = URL.currentDirectory().appendingPathComponent("IP-COUNTRY.csv")
        guard let lineReader = LineReader(path: path.path()) else {
            return false // cannot open file
        }
        self.lines = loadV4Ranges(lineReader: lineReader)
        return true
    }

    func intToLocation(beIP: UInt32) -> IPRange? {
        var lowIndex = 0
        var highIndex = lines.count
        var midIndex = 0
        while lowIndex <= highIndex {
            midIndex = (Int)((lowIndex + highIndex)/2)
            let line = lines[midIndex]
            if beIP >= line.start && beIP < line.end {
                return line
            } else {
                if beIP < line.end {
                    highIndex = midIndex - 1
                } else {
                    lowIndex = midIndex + 1
                }
            }
        }
        return nil
    }
    
    private func loadV4Ranges(lineReader: LineReader) -> [IPRange] {
        
        var ipRanges: [IPRange] = [IPRange]()
        for line in lineReader {
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
