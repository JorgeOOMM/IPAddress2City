//
//  Dictionary+Key.swift
//  IPRanges
//
//  Created by Mac on 11/12/25.
//

extension Dictionary where Value: Equatable {
    func key(from value: Value) -> Key? {
        return first(where: { $1 == value })?.key
    }
}
