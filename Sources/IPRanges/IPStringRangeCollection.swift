//
//  IPStringRangeCollection.swift
//  IPRanges
//
//  Created by Mac on 13/12/25.
//

// MARK: IPStringRangeCollection
class IPStringRangeCollection {
    internal lazy var range = [String]()
    
    init(lower: String, upper: String, ranger: IPAddressGenerator = IPAddressRange()) {
        self.range = ranger.range(lower: lower, upper: upper)
    }
}
// MARK: IPStringRangeCollection: Sequence
extension IPStringRangeCollection: Sequence {
    public func makeIterator() -> IPStringRangeIterator {
        IPStringRangeIterator(self)
    }
}
