//
//  AddressRanges.swift
//  IPRanges
//
//  Created by Mac on 11/12/25.
//
import Foundation

enum CustomError: Error {
    case conversionError
    case locationError
    case memoryError
}

/// AddressRanges is a class that locate a IPRange types from IP Address string
class AddressRanges {
    typealias Handler = (Result<IPRange, Error>) -> Void
    
    private let locator: IPAddressable&LocatorProtocol
    // Don't limit the lifetime of the cache entries
    private lazy var cache = Cache<String, IPRange>(dateProvider: nil)
    private let cacheName: String = "ip.ranges"
    
    init(locator: IPAddressable&LocatorProtocol) {
        self.locator = locator
    }
}

extension AddressRanges {
    func loadLocation(
        with address: String,
        then handler: @escaping Handler
    ) {
        if let cached = cache[address] {
            return handler(.success(cached))
        }
        performLoading(with: address) { [weak self] result in
            let ipRange = try? result.get()
            self?.cache[address] = ipRange
            handler(result)
        }
    }
    func performLoading(
        with address: String,
        then handler: @escaping Handler
    ) {
        guard let beAddress = locator.stringIPToIPNumber(string: address) else {
            handler(.failure(CustomError.conversionError))
            return
        }
        guard let location = locator.locate(from: UInt32(bigEndian: beAddress)) else {
            handler(.failure(CustomError.locationError))
            return
        }
        handler(.success(location))
    }
}

extension AddressRanges {
    func location(with address: String) throws -> IPRange {
        if let cached = cache[address] {
            return cached
        }
        if let addressUInt32 = locator.stringIPToIPNumber(string: address) {
            if let location = locator.locate(from: UInt32(bigEndian: addressUInt32)) {
                self.cache[address] = location
                return location
            }
        } else {
            print("Conversion of address \(address) failed.")
            throw CustomError.conversionError
        }
        print("The address \(address) not found in location database.")
        throw CustomError.locationError
    }
}

extension AddressRanges {
    func start(with range: IPRange) -> String {
        locator.numberIPToStringIP(number: UInt32(bigEndian: range.start))
    }
    func end(with range: IPRange) -> String {
        locator.numberIPToStringIP(number: UInt32(bigEndian: range.end))
    }
    func country(with range: IPRange) -> String {
        guard let country = Countries.shared.names[range.alpha2] else {
            assertionFailure()
            return ""
        }
        return country
    }
    func subdivision(with range: IPRange) -> String {
        range.subdiv
    }
    func flag(with range: IPRange) -> String {
        Countries.flag(from: range.alpha2)
    }
}

extension AddressRanges {
    func saveCache() {
        do {
            try cache.saveToDisk(withName: cacheName)
        } catch {
            print(String(describing: error))
        }
    }
    func loadCache() {
        do {
            cache = try Cache.loadFromDisk(withName: cacheName)
        } catch {
            print(String(describing: error))
        }
    }
}
