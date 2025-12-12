//
//  String+Slice.swift
//  IPRanges
//
//  Created by Mac on 10/12/25.
//

extension String {
    /// slice
    ///
    /// - Parameters:
    ///   - from: String
    ///   - end: String
    ///
    /// - Returns: String?
    ///
    func slice(from: String, end: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else {
            return nil
        }
        guard let rangeTo = self[rangeFrom...].range(of: end)?.lowerBound else {
            return nil
        }
        return String(self[rangeFrom..<rangeTo])
    }
}
