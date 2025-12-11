//
//  main.swift
//  Conversion
//
//  Created by Mac on 11/12/25.
//

import Foundation

let conversor = IPRangesConversor()
if !conversor.load() {
    print("Conversion failed!.")
}
