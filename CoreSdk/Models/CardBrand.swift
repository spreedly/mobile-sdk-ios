//
// Created by Eli Thompson on 5/27/20.
//

import Foundation

typealias BrandDetector = (String) -> Bool

struct BrandParameters {
    let maxLength: Int
    let detect: BrandDetector

    init(max: Int, detect: @escaping BrandDetector) {
        self.maxLength = max
        self.detect = detect
    }
}

public enum CardBrand: String {
    case alelo
    case amex
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
    case vr // swiftlint:disable:this identifier_name

    case unknown

    /// Parses the given string determining and returning the appropriate
    /// brand, otherwise .unknown.
    public static func from(_ number: String?) -> CardBrand {
        guard let number = number?.onlyNumbers() else {
            return .unknown
        }

        return brandData.first(where: { (_, params) in params.detect(number) })?.key ?? .unknown
    }

    var parameters: BrandParameters? {
        brandData[self]
    }

    public var maxLength: Int {
        parameters?.maxLength ?? 19
    }
}

let brandData: [CardBrand: BrandParameters] = [
    .alelo: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.alelo)
            }
    ),
    .amex: BrandParameters(
            max: 15,
            detect: {
                $0.bin(beginning: CardRanges.amex)
            }
    ),
    .cabal: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 8, in: CardRanges.cabal)
            }
    ),
    .carnet: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.carnet) || $0.bin(beginning: CardRanges.carnetBins)
            }
    ),
    .dankort: BrandParameters(
            max: 16,
            detect: {
                $0.bin(beginning: CardRanges.dankort)
            }
    ),
    .dinersClub: BrandParameters(
            max: 19,
            detect: {
                $0.bin(length: 3, in: CardRanges.dinersClub)
            }
    ),
    .discover: BrandParameters(
            max: 19,
            detect: {
                $0.bin(length: 6, in: CardRanges.discover)
            }
    ),
    .elo: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.elo)
            }
    ),
    .forbrubsforeningen: BrandParameters(
            max: 16,
            detect: {
                $0.bin(beginning: CardRanges.forbrubsforeningen)
            }
    ),
    .jcb: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 4, in: CardRanges.jcb)
            }
    ),
    .maestro: BrandParameters(
            max: 19,
            detect: {
                $0.bin(length: 6, in: CardRanges.maestro)
            }
    ),
    .mastercard: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.mastercard)
            }
    ),
    .naranja: BrandParameters(
            max: 16,
            detect: {
                $0.bin(length: 6, in: CardRanges.naranja)
            }
    ),
    .sodexo: BrandParameters(
            max: 16,
            detect: {
                $0.bin(beginning: CardRanges.sodexo)
            }
    ),
    .unionpay: BrandParameters(
            max: 19,
            detect: {
                $0.bin(length: 8, in: CardRanges.unionPay)
            }
    ),
    .visa: BrandParameters(
            max: 19,
            detect: {
                $0.bin(beginning: CardRanges.visa)
            }
    ),
    .vr: BrandParameters(
            max: 16,
            detect: {
                $0.bin(beginning: CardRanges.vr)
            }
    )
]

fileprivate extension String {
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
