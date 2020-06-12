//
// Created by Eli Thompson on 5/15/20.
//

import Foundation
import XCTest
import CoreSdk

class ApplePayTests: XCTestCase {
    func testCanCreateMinimalApplePay() throws {
        let client = Helpers.createClient()
        let info = ApplePayInfo(firstName: "Dolly", lastName: "Dog", paymentTokenData: Helpers.paymentTokenData)
        info.testCardNumber = Helpers.testCardNumber

        let promise = client.createApplePayPaymentMethod(applePay: info)

        let transaction = try promise.assertResult(self)
        let result = transaction.paymentMethod!

        CreditCardTests.assertPaymentMethodFieldsPopulate(result: result, info: info, type: .applePay)
        self.assertCardFieldsPopulate(result: result, info: info)
    }

    func testCanCreateFullApplePay() throws {
        let client = Helpers.createClient()
        let info = ApplePayInfo(firstName: "Dolly", lastName: "Dog", paymentTokenData: Helpers.paymentTokenData)
        info.testCardNumber = Helpers.testCardNumber
        info.company = "LSGD Partners"

        var billing = Address()
        billing.address1 = "123 Fake St"
        billing.address2 = "Suite #200"
        billing.city = "Springfield"
        billing.state = "OR"
        billing.zip = "97475"
        billing.country = "US"
        billing.phoneNumber = "541-555-2222"
        info.address = billing

        var shipping = Address()
        shipping.address1 = "321 Wall St"
        shipping.address2 = "Suite #4100"
        shipping.city = "Seattle"
        shipping.state = "WA"
        shipping.zip = "98121"
        shipping.country = "US"
        shipping.phoneNumber = "206-555-2222"
        info.shippingAddress = shipping

        info.email = "dolly@dog.com"

        let promise = client.createApplePayPaymentMethod(applePay: info)

        let transaction = try promise.assertResult(self)
        let result = transaction.paymentMethod!

        CreditCardTests.assertPaymentMethodFieldsPopulate(result: result, info: info, type: .applePay)
        self.assertCardFieldsPopulate(result: result, info: info)
        XCTAssertEqual(result.email, info.email)

        XCTAssertEqual(result.address, billing)
        XCTAssertEqual(result.shippingAddress, shipping)
    }
}

extension ApplePayTests {
    func assertCardFieldsPopulate(result: ApplePayResult, info: ApplePayInfo) {
        XCTAssertEqual(result.cardType, "visa")
        XCTAssertEqual(result.year, 2022)
        XCTAssertEqual(result.month, 3)

        XCTAssertEqual(result.lastFourDigits, "1111")
        XCTAssertEqual(result.firstSixDigits, "411111")
    }
}
