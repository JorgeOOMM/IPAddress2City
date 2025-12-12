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
        internal var rangeLoader = IPRangesCache()
        
        func locate(address: String) -> IPRange? {
            self.rangeLoader.location(with: address)
        }
    }
}
