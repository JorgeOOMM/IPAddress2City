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

// MARK: IPv4RangeProtocol protocol
protocol IPRangeProtocol {
    var start: UInt32 {get set}
    var end: UInt32 {get set}
}
// MARK: IPv4RangesLocationProtocol protocol
protocol IPRangesLocationProtocol {
    func intToLocation(beIP: UInt32) -> IPRange?
}
// MARK: IPv4RangesLoaderProtocol protocol
protocol IPRangesLoaderProtocol {
    func load() -> Bool
}

//
// Models
//

// MARK: IPv4Range object
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
