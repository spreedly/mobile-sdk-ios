//
// Created by Eli Thompson on 5/27/20.
//

import Foundation

public enum CardBrand: String {
    case visa
    case mastercard
    case discover
    case amex
    case unknown

    /// Parses the given string determining and returning the appropriate
    /// brand, otherwise .unknown.
    public static func from(_ number: String?) -> CardBrand {
        guard let number = number else {
            return .unknown
        }

        let cleanNumber = String(number.filter { $0.isNumber} )
        guard
                let binEnding = cleanNumber.index(number.startIndex, offsetBy: 6, limitedBy: cleanNumber.endIndex),
                let bin = Int(cleanNumber.prefix(upTo: binEnding)) else {
            return .unknown
        }

        switch bin {
        case 400000...499999: // 4
            return .visa
        case 222100...272099, // 2221-2720
             510000...559999: // 51-55
            return .mastercard
        case 601100...601199, // 6011
             622426...622925, // 622126-622925
             644000...649999, // 644-649
             650000...659999: // 65
            return .discover
        case 340000...349999, // 34
             370000...379999: // 37
            return .amex
        default:
            return .unknown
        }
    }
}
