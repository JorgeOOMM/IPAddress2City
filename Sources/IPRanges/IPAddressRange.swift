//
//  IPAddressRange.swift
//
//  Created by Mac on 7/12/25.
//
//  Note: exploding-ipv4-ranges-using-swift
//

import Foundation

// MARK: IPAddressGenerator
protocol IPAddressGenerator {
    func range(lower: String, upper: String) -> [String]
}
// MARK: IPAddressRange
class IPAddressRange: IPAddressConverterLE, IPAddressGenerator {
    func range(lower: String, upper: String) -> [String] {
        guard !(lower.isEmpty || upper.isEmpty) else {
            return []
        }
        guard let lower = stringIPToIPNumber(string: lower) else {
            return []
        }
        guard let upper = stringIPToIPNumber(string: upper) else {
            return []
        }
        guard lower < upper else {
            return []
        }
        var ips: [String] = []
        for index in stride(
            from: lower,
            through: upper,
            by: 1
        ) {
            ips.append(numberIPToStringIP(number: index))
        }
        return ips
    }
}
