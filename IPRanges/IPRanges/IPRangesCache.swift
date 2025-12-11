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
}

class IPRangesCache {
    typealias Handler = (Result<IPRange, Error>) -> Void
    private let ranges = IPRanges()
    // Don't limit the lifetime of the cache entries
    private lazy var cache = Cache<String, IPRange>(dateProvider: nil)
    let cacheName: String = "cache.ip.ranges"
    func loadLocation(withIP address: String,
                      then handler: @escaping Handler) {
        if let cached = cache[address] {
            return handler(.success(cached))
        }
        performLoading(withIP: address) { [weak self] result in
            let ipRange = try? result.get()
            self?.cache[address] = ipRange
            handler(result)
        }
    }
    func location(withIP address: String) -> IPRange? {
        if let cached = cache[address] {
            return cached
        }
        if let ipBigEndian = ranges.stringToInt(address),
           let location = ranges.intToLocation(beIP: UInt32(bigEndian: ipBigEndian)) {
            self.cache[address] = location
            return location
        }
        print("*** \(address) not found in location database. [TO ADD IT]")
        return nil
    }
    func performLoading(withIP address: String,
                        then handler: @escaping Handler) {
        guard let beAddress = ranges.stringToInt(address) else {
            handler(.failure(CustomError.conversionError))
            return
        }
        guard let location = ranges.intToLocation(beIP: UInt32(bigEndian: beAddress)) else {
            handler(.failure(CustomError.locationError))
            return
        }
        handler(.success(location))
    }
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
