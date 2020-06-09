//
// Created by Eli Thompson on 6/2/20.
//

import XCTest
@testable import CoreSdk

class CardBrandTests: XCTestCase {
    func testWhenValidNumberShouldDetermineBrand() {
        // Spreedly test numbers
        XCTAssertEqual(CardBrand.from("5067 7052 3209 2752"), CardBrand.alelo)
        XCTAssertEqual(CardBrand.from("3782 8224 6310 005 "), CardBrand.amex)
        XCTAssertEqual(CardBrand.from("5062 2800 0000 0002"), CardBrand.carnet)
        XCTAssertEqual(CardBrand.from("6035 2277 1642 7021"), CardBrand.cabal)
        XCTAssertEqual(CardBrand.from("5019 7170 1010 3742"), CardBrand.dankort)
        XCTAssertEqual(CardBrand.from("6011 1111 1111 1117"), CardBrand.discover)
        XCTAssertEqual(CardBrand.from("3056 9309 0259 04  "), CardBrand.dinersClub)
        XCTAssertEqual(CardBrand.from("6011 1111 1111 1117"), CardBrand.discover)
        XCTAssertEqual(CardBrand.from("5067 3100 0000 0010"), CardBrand.elo)
        XCTAssertEqual(CardBrand.from("3569 9900 1003 0400"), CardBrand.jcb)
        XCTAssertEqual(CardBrand.from("6759000000000000005"), CardBrand.maestro)
        XCTAssertEqual(CardBrand.from("5555 5555 5555 4444"), CardBrand.mastercard)
        XCTAssertEqual(CardBrand.from("5895 6278 2345 3005"), CardBrand.naranja)
        XCTAssertEqual(CardBrand.from("4111 1111 1111 1111"), CardBrand.visa)
        XCTAssertEqual(CardBrand.from("4444333322221111455"), CardBrand.visa)
    }

    func testWhenNumberIdentifiableShouldDetermineBrand() {
        // Unofficial numbers
        XCTAssertEqual(CardBrand.from("600722             "), CardBrand.forbrubsforeningen)
        XCTAssertEqual(CardBrand.from("606071             "), CardBrand.sodexo)
        XCTAssertEqual(CardBrand.from("81000099           "), CardBrand.unionpay)
        XCTAssertEqual(CardBrand.from("627416             "), CardBrand.vr)
    }

    func testWhenInvalidNumberShouldDetermineUnknown() {
        XCTAssertEqual(CardBrand.from(nil), CardBrand.unknown)
        XCTAssertEqual(CardBrand.from("1234 5             "), CardBrand.unknown)
        XCTAssertEqual(CardBrand.from("0000 0000 0000 0000"), CardBrand.unknown)
    }

    func testCanReadMaxLength() {
        XCTAssertEqual(CardBrand.visa.maxLength, 19)
    }
}
