//
//  Test+Time.swift
//  IPRanges
//
//  Created by Mac on 12/12/25.
//

import Foundation

func timeTest( _ function: () -> Void) -> (Double) {
    let start = Date()
    function()
    let end = Date()
    let time = end.timeIntervalSince(start)
    return (time)
}

func test( _ function: () -> Void) {
    let timer = timeTest {
        function()
    }
    print("\(timer * 1000.0) ms")
}
