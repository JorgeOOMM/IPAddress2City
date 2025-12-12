//
//  IPRangesConverter.swift
//  IPRanges
//
//  Created by Mac on 9/12/25.
//

import Foundation

// MARK: IPRangesConverter object
class IPRangesConverter: IPRangesTextFileLineLoader  {
    
    /// preparePlaceElement
    ///
    ///   Fix the elements that contain the character "-", used for separate the places
    ///
    /// - Parameter item: String
    /// - Returns: String
    ///
    fileprivate func preparePlaceElement(_ item: String) -> String {
        var result = item
        if let slices = result.slice(from: "(", to: ")")?.split(separator: " - "),
            slices.count > 1 {
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
        return result
    }
    
    /// performConversion
    /// 
    /// - Returns: Bool
    fileprivate func performConversion(to directory: URL) -> Bool {
        let uniquePlaces = NSMutableOrderedSet()
        var ranges = [IPRangeIndexed]()
        
        for currentLine in self.lines {
            // Fix the elements that contain the character "-", used for separate the places
            let newPlaceElement = preparePlaceElement(currentLine.place)
            let place = newPlaceElement.split(separator: " - ")
            var result = ""
            if place.count == 1 {
                // Don't save the country because the alpha2 contains it
                // Case for 1 item
                // Antarctica
                continue
            }
            else if place.count == 2 {
                // Case for 2 items
                // Singapore (Tanjong Pagar) - Singapore
                result = String(place[0])
            } else {
                // Case for 3 items
                // Paterna - Valencia - España
                result = String(place[0]) + "#" + String(place[1])
            }

            // Add the line place
            uniquePlaces.add(result)
            
            // Get the alpha2 code
            if let alpha2 = Countries.numericISO[currentLine.alpha2] {
                
                // Get the index of the place at the array
                let index = uniquePlaces.index(of: result)
                if index != NSNotFound {
                    ranges.append(IPRangeIndexed(start: currentLine.start,
                                         end: currentLine.end,
                                                   alpha2: alpha2,
                                                       placeIndex: UInt32(index)))
                } else {
                    ranges.append(IPRangeIndexed(start: currentLine.start,
                                         end: currentLine.end,
                                                       alpha2:alpha2,
                                         placeIndex: UInt32(0xffffffff)))
                }
            } else {
                assertionFailure("The alpha2 code \(currentLine.alpha2) it not in the Countries.numericISO dictionary.")
                return false
            }
        }
        
        do {
            
            let dataURL =
            directory.appendingPathComponent("IP-COUNTRY.bin")
            
            let dataURLPlaces =
            directory.appendingPathComponent("COUNTRY-PLACES.bin")
            
            try arrayToFile(array: ranges, toFile: dataURL)
            
            try arrayToFileString(array: uniquePlaces.array as! [String],
                             toFile: dataURLPlaces)
            
        } catch {
            print("Unable to save the conversion result. Error: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    /// Save the result of conversion
    ///
    /// - Parameter url: Directory URL
    /// - Returns: Bool
    ///
    func save(to url: URL) -> Bool {
        return self.performConversion(to: url)
    }
}

