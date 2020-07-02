//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import Spreedly
import XCTest

class AddressTests: XCTestCase {
    func createAddress() -> Address {
        let address = Address()
        address.address1 = "123 Fake St"
        address.address2 = "Suite 200"
        address.city = "Seattle"
        address.state = "WA"
        address.zip = "98121"
        address.country = "US"
        address.phoneNumber = "206-555-5555"
        return address
    }

    func testWhenSameShouldBeEqual() {
        XCTAssertEqual(createAddress(), createAddress())
    }

    func testWhenDifferentShouldNotBeEqual() {
        let first = createAddress()
        let second = createAddress()
        second.address2 = "Suite 201"
        XCTAssertNotEqual(first, second)
    }

    func testWhenDifferentTypesShouldNotBeEqual() {
        let address = createAddress()
        XCTAssertFalse(address.isEqual(CreditCardInfo()))
    }
}
