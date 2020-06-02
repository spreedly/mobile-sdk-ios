//
// Created by Eli Thompson on 6/2/20.
//

import XCTest
@testable import CoreSdk

class CardBrandTests: XCTestCase {
    func testWhenValidNumberShouldDetermineBrand() {
        XCTAssertEqual(CardBrand.from("4111 1111 1111 1111"), CardBrand.visa)
        XCTAssertEqual(CardBrand.from("5555 5555 5555 4444"), CardBrand.mastercard)
        XCTAssertEqual(CardBrand.from("6011 1111 1111 1117"), CardBrand.discover)
        XCTAssertEqual(CardBrand.from("3782 8224 6310 005 "), CardBrand.amex)
    }

    func testWhenInvalidNumberShouldDetermineUnknown() {
        XCTAssertEqual(CardBrand.from(nil), CardBrand.unknown)
        XCTAssertEqual(CardBrand.from("1234 5             "), CardBrand.unknown)
        XCTAssertEqual(CardBrand.from("0000 0000 0000 0000"), CardBrand.unknown)
    }
}
