//
//  IPRangesConverter.swift
//  IPRanges
//
//  Created by Mac on 9/12/25.
//

import Foundation

// MARK: IPRangesConverter object
class IPRangesConverter: IPRangesTextFileLineLoader {
    /// prepareSubdiv
    ///
    ///   Fix the elements that contain the character "-", used for separate the places
    ///
    /// - Parameter item: String
    ///
    /// - Returns: String
    ///
    fileprivate func prepareSubdiv(subdiv: String) -> String {
        var result = subdiv
        if let slices = result.slice(from: "(", end: ")")?.split(separator: " - ") {
            if slices.count > 1 {
                if slices.count == 2 {
                    result = result.replacingOccurrences(
                        of: "(\(slices[0]) - \(slices[1])",
                        with: "(\(slices[0])-\(slices[1])"
                    )
                } else if slices.count == 3 {
                    result = result.replacingOccurrences(
                        of: "(\(slices[0]) - \(slices[1]) - \(slices[2])",
                        with: "(\(slices[0])-\(slices[1])-\(slices[2])"
                    )
                } else if slices.count == 4 {
                    result = result.replacingOccurrences(
                        of: "(\(slices[0]) - \(slices[1]) - \(slices[2]) - \(slices[3])",
                        with: "(\(slices[0])-\(slices[1])-\(slices[2])-\(slices[3])"
                    )
                } else {
                    assertionFailure()
                }
            }
        }
        return result
    }
    
    /// processSubdiv
    ///
    /// - Parameter place: String
    ///
    /// - Returns: String?
    ///
    fileprivate func processSubdiv(subdiv: String) -> String? {
        // Fix the elements that contain the character "-", used for separate the places
        let newSubdiv = prepareSubdiv(subdiv: subdiv)
        let place = newSubdiv.split(separator: " - ")
        var result: String?
        if place.count == 1 {
            // Don't save the country because the alpha2 contains it
            // Case for 1 item
            // Antarctica
        } else if place.count == 2 {
            // Case for 2 items
            // Singapore (Tanjong Pagar) - Singapore
            result = String(place[0])
        } else {
            // Case for 3 items
            // Paterna - Valencia - España
            result = String(place[0]) + "#" + String(place[1])
        }
        return result
    }
    /// performConversion
    /// 
    /// - Parameter directory: URL
    ///
    /// - Returns: Bool
    ///
    fileprivate func performConversion(to directory: URL) -> Bool {
        let uniqueSubdivs = NSMutableOrderedSet()
        var ranges = [IPRangeIdx]()
        
        for line in self.lines {
            if let alpha2Idx = Countries.shared.indexes[line.alpha2] {
                if let result = processSubdiv(subdiv: line.subdiv) {
                    // Add the subdivision line
                    uniqueSubdivs.add(result)
                    // Get the index of the place at the array
                    let index = uniqueSubdivs.index(of: result)
                    if index != NSNotFound {
                        ranges.append(IPRangeIdx(
                            start: line.start,
                            end: line.end,
                            alpha2Idx: alpha2Idx,
                            subdivIdx: UInt32(index)))
                    }
                } else {
                    ranges.append(IPRangeIdx(
                        start: line.start,
                        end: line.end,
                        alpha2Idx: alpha2Idx,
                        subdivIdx: UInt32(0xffffffff))
                    )
                }
            } else {
                assertionFailure("The alpha2 code \(line.alpha2) it not valid index.")
                return false
            }
        }
        
        do {
            
            let dataURL =
            directory.appendingPathComponent("IP-COUNTRY.bin")
            
            let dataURLSubdivs =
            directory.appendingPathComponent("COUNTRY-SUBDIVS.bin")
            
            try arrayToFile(array: ranges, to: dataURL)
            
            if let array = uniqueSubdivs.array as? [String] {
                try arrayToFileString(
                    array: array,
                    to: dataURLSubdivs
                )
            }
            
        } catch {
            print("Unable to save the conversion result. Error: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    /// Save the result of conversion
    ///
    /// - Parameter url: Directory URL
    ///
    /// - Returns: Bool
    ///
    func save(to url: URL) -> Bool {
        self.performConversion(to: url)
    }
}
