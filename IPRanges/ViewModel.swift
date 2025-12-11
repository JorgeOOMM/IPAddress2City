//
//  ViewModel.swift
//  IPRange
//
//  Created by Mac on 8/12/25.
//

import SwiftUI

// MARK: ContentView
extension ContentView {
    @Observable
    class ViewModel {
        internal var rangeLoader: IPRangesCache = IPRangesCache()
        func locate(address: String) -> IPRange? {
            return self.rangeLoader.location(withIP: address)
        }
    }
}
