//
//  IPRange.swift
//
//  Created by Mac on 18/9/24.
//

import Foundation

//  There are three type of operations needed for the correct work of the code
//
//  1 - Converter need to read a csv file and convert to compressed binary files.
//  2 - The app/library need to has in its resources the compressed binaries files.
//  3 - IPRanges need to decompress a binary files from Resources and move to Documents

// MARK: IPRanges object
class IPRanges {
    private var locator: LocationProtocol
    
    init(locator: LocationProtocol) {
        
        // Initialize the interface
        self.locator = locator
        
        // Prepare the infrastructure
        if !load() {
            print("Unable to prepare the basic infrastructure.")
        }
        
        if !self.locator.load() {
            print("Unable to prepare the basic infrastructure.")
        }
        
        printRangeOfAddress()
    }
}

extension IPRanges {
    func printRangeOfAddress(address: String = "102.130.125.86") {
        
        print("Printing range record for: \(address)")
        
        guard let addressUInt32 = stringToInt(address) else {
            return
        }
        
        guard let location = location(from: UInt32(bigEndian: addressUInt32)) else {
            return
        }
        
        let country = country(range: location) ?? ""
        let flag = flag(range: location) ?? ""
        
        print("\(intToString(UInt32(bigEndian: location.start))), \(intToString(UInt32(bigEndian: location.end))), \(country) [\(flag)], \(location.subdiv)")
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
    
}
extension IPRanges: LocationProtocol {
    func location(from address: UInt32) -> IPRange? {
        locator.location(from: address)
    }
}

extension IPRanges {
    func country(range: IPRange) -> String? {
        Countries.shared.names[range.alpha2]
    }
    func flag(range: IPRange) -> String? {
        Countries.flag(from: range.alpha2)
    }
}

extension IPRanges {
    /// Decompresing the binary files from Resource directory to Documents directory
    ///
    /// - Returns: Bool
    ///
    func load() -> Bool {
        let rangesPath = URL.documentsDirectory.appendingPathComponent("IP-COUNTRY.bin")
        if !FileManager.default.fileExists(atPath: rangesPath.path()) {
            
            if !Compressor.decompressFromResources(
                fileName: "IP-COUNTRY",
                withExtension: "bin",
                to: rangesPath
            ) {
                return false
            }
        }
        let subdivsPath = URL.documentsDirectory.appendingPathComponent("COUNTRY-SUBDIVS.bin")
        
        if !FileManager.default.fileExists(atPath: subdivsPath.path()) {
            
            if !Compressor.decompressFromResources(
                fileName: "COUNTRY-SUBDIVS",
                withExtension: "bin",
                to: subdivsPath
            ) {
                return false
            }
        }
        return true
    }
}
