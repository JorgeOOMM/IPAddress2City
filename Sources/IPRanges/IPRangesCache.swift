//
//  IPRangesCache.swift
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

class IPRangesCache {
    typealias Handler = (Result<IPRange, Error>) -> Void
    // TODO: ranges: LocationProtocol
    private let ranges = IPRanges(locator: IPRangesBinaryFileReader())
    // Don't limit the lifetime of the cache entries
    private lazy var cache = Cache<String, IPRange>(dateProvider: nil)
    let cacheName: String = "ip.ranges"
}

extension IPRangesCache {
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
        guard let beAddress = ranges.stringToInt(address) else {
            handler(.failure(CustomError.conversionError))
            return
        }
        guard let location = ranges.location(from: UInt32(bigEndian: beAddress)) else {
            handler(.failure(CustomError.locationError))
            return
        }
        handler(.success(location))
    }
}

extension IPRangesCache {
    func location(with address: String) -> IPRange? {
        if let cached = cache[address] {
            return cached
        }
        if let addressUInt32 = ranges.stringToInt(address),
           let location = ranges.location(from: UInt32(bigEndian: addressUInt32)) {
            self.cache[address] = location
            return location
        }
        print("*** \(address) not found in location database.")
        return nil
    }
}

extension IPRangesCache {
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
