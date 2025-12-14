//
//  CountryNames.swift
//
//  Created by Mac on 18/9/24.
//
import Foundation

// swiftlint:disable legacy_objc_type
class Countries {
    var locale: Locale
    
    init(identifier: String) {
        self.locale = Locale(identifier: identifier)
    }
    static func flag(from country: String) -> String {
        // The flags start at code point 0x1F1E6. The offset for "A" is 65. 0x1F1E6 - 65 = 127397
        let base: UInt32 = 127397
        var output = ""
        for unicodeScalars in country.uppercased().unicodeScalars {
            output.unicodeScalars.append(UnicodeScalar(base + unicodeScalars.value)!)
        }
        return output
    }
    
    lazy var names: [String: String] = {
        var countries: [String: String] = [:]
        for code in NSLocale.isoCountryCodes {
            let id: String = Locale.identifier(fromComponents: [
                NSLocale.Key.countryCode.rawValue: code
            ])
            guard let name = (self.locale as NSLocale).displayName(
                forKey: .identifier,
                value: id
            ) else {
                continue
            }
            countries[code] = name
        }
        return countries
    }()
    
    lazy var indexes: [String: UInt32] = {
        var indexes: [String: UInt32] = [:]
        for (index, code) in NSLocale.isoCountryCodes.enumerated() {
            indexes[code] = UInt32(index + 1)
        }
        return indexes
    }()
}

extension Countries {
    static var shared = Countries(identifier: "en_EN")
}

// swiftlint:enable legacy_objc_type
