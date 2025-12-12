//
//  IPRange.swift
//
//  Created by Mac on 18/9/24.
//

import Foundation

//let DEBUG_LOAD = 1

/*
  There are three type of operations needed for the correct work of the code
 
  1 - Converter need to read a csv file and convert to compressed binary files.
  2 - The app/library need to has in its resources the compressed binaries files.
  2 - IPRanges need to decompress a binary files from Resources and move to Documents
 
 */

// MARK: IPRanges object
class IPRanges: LocationProtocol {
    private var locator: LocationProtocol
    private var countries: Countries

    func printRangeOfAddress(ip: String = "102.130.125.86") {
        
        print("Printing IPRange record: \(ip)")
        
        guard let ip = stringToInt(ip) else { return }
        
        let ip_big = UInt32(bigEndian: ip)
        
        guard let location = location(from: ip_big) else { return }
        
        print("\(location.start), \(location.end), \(location.alpha2), \(location.place)")
    }
    
    func intToString(_ value: UInt32) -> String {
        let addr = in_addr(s_addr: value)
        return String(cString: inet_ntoa(addr))
    }
    func stringToInt(_ value: String) -> UInt32? {
        var addr = in_addr()
        return inet_aton(value.cString(using: .ascii), &addr) != 0
        ? UInt32(addr.s_addr)
        : nil
    }
    func location(from address: UInt32) -> IPRange? {
        return locator.location(from: address)
    }
    func country(range: IPRange) -> String? {
        return countries.names[range.alpha2]
    }
    func flag(range: IPRange) -> String? {
         return Countries.flag(from: range.alpha2)
    }
    
    init(locator: LocationProtocol, identifier: String = "es_ES") {
        
        // Initialize the interfaces
        self.countries = Countries(identifier: identifier)
        self.locator = locator
        
        if !decompressBinFiles() {
            print("Unable to prepare the basic infrastructure.")
        }
    
//        if DEBUG_LOAD != 0 {
//            self.testLoad()
//        } else {
//            if !self.reader.load() {
//                print("Unable to load the needed information.")
//            }
//        }
    }
}


extension IPRanges {
    /// Move decompresing the bins files from Resource directory to Documents directory in the sandbox
    ///
    /// - Returns: Bool
    ///
    fileprivate func decompressBinFiles() -> Bool {
        let rangesPath = URL.documentsDirectory.appendingPathComponent("IP-COUNTRY.bin")
        if !FileManager.default.fileExists(atPath: rangesPath.path()) {
            
            if(!Compressor.decompressFromResources(fileName: "IP-COUNTRY",
                                                   withExtension: "bin",
                                                  to: rangesPath)) {
                return false
            }
        }
        let placesPath = URL.documentsDirectory.appendingPathComponent("COUNTRY-PLACES.bin")
        
        if !FileManager.default.fileExists(atPath: placesPath.path()) {
            
            if(!Compressor.decompressFromResources(fileName: "COUNTRY-PLACES",
                                                   withExtension: "bin",
                                                  to: placesPath)) {
                return false
            }
        }
        return true
    }
}


//extension IPRanges {
//    func timeOneTest( _ function: () -> Void) -> (Double)  {
//        let start = Date()
//        function()
//        let end = Date()
//        let time = end.timeIntervalSince(start)
//        return (time)
//    }
//    
//    func testLoad() {
//    
//        let timer = timeOneTest() {
//            _ = self.reader.load()
//        }
//        print("Reader loaded correctly. \(timer * 1000.0) ms")   // Fileline: 364 MB max: 364 35845.84093093872 ms
//                                                                 // Content: 367 MB max: 1017 40996.81997299194 ms
//                                                                 // Content2: 288 MB max: 1005 53829.3240070343 ms
//                                                                 // Binary: 19.6 MB max: 19 134.18409824371338 ms
//                                                                 // Conv:    365 MB max: 422  73905.17199039459 ms
//        printRangeOfAddress()
//    }
//}
