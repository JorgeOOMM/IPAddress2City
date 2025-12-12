//
//  Model.swift
//  IPRanges
//
//  Created by Mac on 11/12/25.
//

import Foundation

//
// Protocols
//

// MARK: IPRangeProtocol protocol
protocol IPRangeProtocol {
    var start: UInt32 {get set}
    var end: UInt32 {get set}
}

///
/// This protocol has the interface for locate the `IPRange` location for a ip `address`
///
/// let address: UInt32 = 16777216
/// let range: IPRange? = locator.location(from: address)
///

// MARK: LocationProtocol protocol
protocol LocationProtocol {
    // IP (Internet Protocol) uses big-endian byte order, also known as network byte order
    func location(from address: UInt32) -> IPRange?
}

// MARK: LoaderProtocol protocol
protocol LoaderProtocol {
    /// The target directory of the conversion
    func load(from url: URL) -> Bool
}

//
// Models
//

// MARK: IPRange object (Internet Protocol version 4 (IPv4))
struct IPRange: IPRangeProtocol, Codable {
    var start: UInt32
    var end: UInt32
    var alpha2: String
    var place: String
}

struct IPRangeIndexed: IPRangeProtocol {
    var start: UInt32
    var end: UInt32
    var alpha2: UInt32
    var placeIndex: UInt32
}
