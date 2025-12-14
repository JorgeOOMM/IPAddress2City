//
//  IPAddressRangeLocator.swift
//
//  Created by Mac on 18/9/24.
//

import Foundation

//  There are three type of operations needed for the correct work of the code
//
//  1 - Converter need to read a csv file and convert to compressed binary files.
//  2 - The app/library need to has in its resources the compressed binaries files.
//  3 - IPRanges need to decompress a binary files from Resources and move to Documents

// MARK: IPAddressRangeLocator object
class IPAddressRangeLocator: IPAddressConverterBE {
    private var locator: LocatorProtocol
    
    init(locator: LocatorProtocol = BinaryFileLocator()) {
        
        // Initialize the LocatorProtocol interface
        self.locator = locator
        
        super.init()
        
        // Prepare the infrastructure
        if !load() {
            print("Unable to prepare the basic infrastructure.")
        }
        
        printAddress(for: "102.130.125.86")
    }
}

protocol AddressPrintable {
    func printAddress(for address: String)
}

// MARK: IPAddressRangeLocator
extension IPAddressRangeLocator: AddressPrintable {
    func printAddress(for address: String) {
        
        print("Printing range record for: \(address)")
        
        guard let addressUInt32 = stringIPToIPNumber(string: address),
              let location = locate(from: UInt32(bigEndian: addressUInt32)) else {
            return
        }
        
        let country = Countries.shared.names[location.alpha2] ?? ""
        
        print(
            numberIPToStringIP(number: UInt32(bigEndian: location.start)),
            numberIPToStringIP(number: UInt32(bigEndian: location.end)),
            country,
            Countries.flag(from: location.alpha2),
            location.subdiv
        )
    }
}

// MARK: LocatorProtocol
extension IPAddressRangeLocator: LocatorProtocol {
    func locate(from address: UInt32) -> IPRange? {
        // Delegate in the inner locator
        locator.locate(from: address)
    }
    
    /// Decompresing the binary files from Resource directory to Documents directory if not exist
    ///
    /// - Parameters:
    ///   - fileName: String
    ///   - withExtension: String
    ///
    /// - Returns: Bool
    ///
    fileprivate func copyResourcesIfNeeded(fileName: String, withExtension: String) -> Bool {
        let path = URL.documentsDirectory.appendingPathComponent("\(fileName).\(withExtension)")
        var result = true
        if !FileManager.default.fileExists(atPath: path.path()) {
            // Decompress the file
            if !Compressor.decompressFromResources(
                fileName: fileName,
                withExtension: withExtension,
                to: path
            ) {
                result = false
            }
        }
        return result
    }
    
    /// Load the needed resources
    ///
    /// - Returns: Bool
    ///
    func load() -> Bool {
        // Copy the bundle resouces needed
        if copyResourcesIfNeeded(fileName: "IP-COUNTRY", withExtension: "bin") &&
            copyResourcesIfNeeded(fileName: "COUNTRY-SUBDIVS", withExtension: "bin") {
            // Load the locator
            return self.locator.load()
        }
        return true
    }
}
