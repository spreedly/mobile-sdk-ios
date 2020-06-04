//
// Created by Eli Thompson on 5/27/20.
//

import Foundation

typealias BrandDetector = (String) -> Bool
typealias BrandMaxLength = (String) -> Int

struct BrandParameters {
    private let _maxLength: BrandMaxLength
    let detect: BrandDetector

    init(length: Int, detect: @escaping BrandDetector) {
        self._maxLength = { _ in
            length
        }
        self.detect = detect
    }

    init(length: @escaping BrandMaxLength, detect: @escaping BrandDetector) {
        self._maxLength = length
        self.detect = detect
    }

    func maxLength(number: String?) -> Int {
        self._maxLength(number ?? "")
    }
}

public enum CardBrand: String {
    case amex
    case alelo
    case cabal
    case carnet
    case dankort
    case dinersClub
    case discover
    case elo
    case forbrubsforeningen
    case jcb
    case maestro
    case mastercard
    case naranja
    case sodexo
    case unionpay
    case visa
    case vr
    case unknown

    var defaultMaxLength: Int {
        19
    }

    /// Parses the given string determining and returning the appropriate
    /// brand, otherwise .unknown.
    public static func from(_ number: String?) -> CardBrand {
        guard let number = number?.onlyNumbers() else {
            return .unknown
        }

        return brandData.first(where: {(_, params) in params.detect(number) })?.key ?? .unknown
    }

    var parameters: BrandParameters? {
        brandData[self]
    }

    public func maxLength(number: String?) -> Int {
        guard let parameters = parameters else {
            return defaultMaxLength
        }
        return parameters.maxLength(number: number)
    }
}


let brandData: [CardBrand: BrandParameters] = [
    .alelo: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.alelo)
            }
    ),
    .amex: BrandParameters(
            length: 15,
            detect: {
                $0.bin(beginning: CardRanges.amex)
            }
    ),
    .cabal: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 8, in: CardRanges.cabal)
            }
    ),
    .carnet: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.carnet) || $0.bin(beginning: CardRanges.carnetBins)
            }
    ),
    .dankort: BrandParameters(
            length: 16,
            detect: {
                $0.bin(beginning: CardRanges.dankort)
            }
    ),
    .dinersClub: BrandParameters(
            length: 19,
            detect: {
                $0.bin(length: 3, in: CardRanges.dinersClub)
            }
    ),
    .discover: BrandParameters(
            length: 19,
            detect: {
                $0.bin(length: 6, in: CardRanges.discover)
            }
    ),
    .elo: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.elo)
            }
    ),
    .forbrubsforeningen: BrandParameters(
            length: 16,
            detect: {
                $0.bin(beginning: CardRanges.forbrubsforeningen)
            }
    ),
    .jcb: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 4, in: CardRanges.jcb)
            }
    ),
    .maestro: BrandParameters(
            length: 19,
            detect: {
                $0.bin(length: 6, in: CardRanges.maestro)
            }
    ),
    .mastercard: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.mastercard)
            }
    ),
    .naranja: BrandParameters(
            length: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.naranja)
            }
    ),
    .sodexo: BrandParameters(
            length: 16,
            detect: {
                $0.bin(beginning: CardRanges.sodexo)
            }
    ),
    .unionpay: BrandParameters(
            length: 19,
            detect: {
                $0.bin(length: 8, in: CardRanges.unionPay)
            }
    ),
    .visa: BrandParameters(
            length: 19,
            detect: {
                $0.bin(beginning: CardRanges.visa)
            }
    ),
    .vr: BrandParameters(
            length: 16,
            detect: {
                $0.bin(beginning: CardRanges.vr)
            }
    )
]

extension String {
    func bin(length: Int, in binRanges: [ClosedRange<Int>]) -> Bool {
        let cleaned = self.onlyNumbers()
        guard cleaned.count >= length,
              let bin = Int(cleaned.prefix(length)) else {
            return false
        }
        return binRanges.contains { range in
            range.contains(bin)
        }
    }

    func bin(beginning bins: [String]) -> Bool {
        let cleaned = self.onlyNumbers()

        return bins.contains(where: { bin in
            bin == cleaned.prefix(bin.count)
        })
    }

    func onlyNumbers() -> String {
        String(self.filter {
            $0.isNumber
        })
    }
}
