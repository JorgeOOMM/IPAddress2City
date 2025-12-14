//
//  IPStringRangeIterator.swift
//  IPRanges
//
//  Created by Mac on 12/12/25.
//

// MARK: IPStringRangeIterator
class IPStringRangeIterator {
    
    private let collection: IPStringRangeCollection
    private var index = 0
    
    init(_ collection: IPStringRangeCollection) {
        self.collection = collection
    }
}
// MARK: IPStringRangeIterator: IteratorProtocol
extension IPStringRangeIterator: IteratorProtocol {
    func next() -> String? {
        defer { index += 1 }
        return index < self.collection.range.count ? collection.range[index] : nil
    }
}
