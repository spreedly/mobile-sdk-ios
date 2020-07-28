//
// Created by Stefan Rusek on 5/6/20.
//

import XCTest
import Spreedly

class CreditCardTests: XCTestCase {
    func testCanCreateMinimalCreditCard() throws {
        let client = Helpers.createClient()
        let info = Helpers.initCreditCard()

        let promise = client.createPaymentMethodFrom(creditCard: info)
        let transaction = try promise.assertResult(self)
        let result = transaction.creditCard!

        CreditCardTests.assertPaymentMethodFieldsPopulate(result: result, info: info, type: .creditCard)
        CreditCardTests.assertCardFieldsPopulate(result: result, info: info)
    }

    func testCanCreateFullCreditCard() throws {
        let client = Helpers.createClient()
        let info = Helpers.initCreditCard()

        let billing = buildAddress()
        info.address = billing

        let shipping = buildShippingAddress()
        info.shippingAddress = shipping

        info.email = "dolly@dog.com"

        info.metadata = [
            "stringKey": "correcthorsebatterystaple",
            "intKey": 42,
            "doubleKey": 3.14,
            "boolKey": false
        ]

        let promise = client.createPaymentMethodFrom(creditCard: info)
        let transaction = try promise.assertResult(self)
        let result = transaction.creditCard!

        CreditCardTests.assertPaymentMethodFieldsPopulate(result: result, info: info, type: .creditCard)
        CreditCardTests.assertCardFieldsPopulate(result: result, info: info)
        XCTAssertNil(result.callbackUrl)
        XCTAssertEqual(result.email, info.email)

        XCTAssertEqual(result.address, billing)
        XCTAssertEqual(result.shippingAddress, shipping)

        XCTAssertEqual(result.metadata?["stringKey"] as? String, "correcthorsebatterystaple")
        XCTAssertEqual(result.metadata?["intKey"] as? Int, 42)
        XCTAssertEqual(result.metadata?["doubleKey"] as? Double, 3.14)
        XCTAssertEqual(result.metadata?["boolKey"] as? Bool, false)
    }

    func buildAddress() -> Address {
        let address = Address()
        address.address1 = "123 Fake St"
        address.address2 = "Suite #200"
        address.city = "Springfield"
        address.state = "OR"
        address.zip = "97475"
        address.country = "US"
        address.phoneNumber = "541-555-2222"
        return address
    }

    func buildShippingAddress() -> Address {
        let address = Address()
        address.address1 = "321 Wall St"
        address.address2 = "Suite #4100"
        address.city = "Seattle"
        address.state = "WA"
        address.zip = "98121"
        address.country = "US"
        address.phoneNumber = "206-555-2222"
        return address
    }
}

extension CreditCardTests {
    // MARK: - Credit card specific asserts

    static func assertPaymentMethodFieldsPopulate(
            result: PaymentMethodResultBase,
            info: PaymentMethodInfo,
            type paymentMethodType: PaymentMethodType
    ) {
        XCTAssertNotNil(result.token)
        XCTAssertEqual(result.storageState, StorageState.cached)
        XCTAssertEqual(result.test, true)
        XCTAssertEqual(result.paymentMethodType, paymentMethodType)

        XCTAssertEqual(result.firstName, info.firstName)
        XCTAssertEqual(result.lastName, info.lastName)
        XCTAssertEqual(result.fullName, "\(info.firstName!) \(info.lastName!)")
        XCTAssertEqual(result.company, info.company)
    }

    static func assertCardFieldsPopulate(result: CreditCardResult, info: CreditCardInfo) {
        XCTAssertEqual(result.cardType, "visa")
        XCTAssertEqual(result.year, info.year)
        XCTAssertEqual(result.month, info.month)

        XCTAssertEqual(result.lastFourDigits, "1111")
        XCTAssertEqual(result.firstSixDigits, "411111")
        XCTAssertEqual(result.number, "XXXX-XXXX-XXXX-1111")
        XCTAssertNotNil(result.fingerprint)
    }
}
