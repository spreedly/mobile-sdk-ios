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

    func testCanCreateMinimalCreditCardNoName() throws {
        let client = Helpers.createClient()
        let info = Helpers.initCreditCard()

        info.allowBlankName = true
        info.firstName = nil
        info.lastName = nil

        let promise = client.createPaymentMethodFrom(creditCard: info)
        let transaction = try promise.assertResult(self)
        let result = transaction.creditCard!

        CreditCardTests.assertPaymentMethodFieldsPopulate(result: result, info: info, type: .creditCard)
        CreditCardTests.assertCardFieldsPopulate(result: result, info: info)
    }

    func testCanCreateMinimalCreditCardNoDate() throws {
        let client = Helpers.createClient()
        let info = Helpers.initCreditCard()

        info.allowBlankDate = true
        info.year = nil
        info.month = nil

        let promise = client.createPaymentMethodFrom(creditCard: info)
        let transaction = try promise.assertResult(self)
        let result = transaction.creditCard!

        CreditCardTests.assertPaymentMethodFieldsPopulate(result: result, info: info, type: .creditCard)
        CreditCardTests.assertCardFieldsPopulate(result: result, info: info)
    }

    func testCanCreateFullCreditCard() throws {
        let client = Helpers.createClient()
        let info = Helpers.initCreditCard()

        let billing = Helpers.buildAddress()
        info.address = billing

        let shipping = Helpers.buildShippingAddress()
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
}

extension CreditCardTests {
    // MARK: - Credit card specific asserts

    static func assertPaymentMethodFieldsPopulate(
            result: PaymentMethodResult,
            info: PaymentMethodInfo,
            type paymentMethodType: PaymentMethodType
    ) {
        XCTAssertNotNil(result.token)
        XCTAssertEqual(result.storageState, StorageState.cached)
        XCTAssertEqual(result.test, true)
        XCTAssertEqual(result.paymentMethodType, paymentMethodType)

        XCTAssertEqual(result.firstName, info.firstName)
        XCTAssertEqual(result.lastName, info.lastName)
        if (!info.allowBlankName) {
            XCTAssertEqual(result.fullName, "\(info.firstName!) \(info.lastName!)")
        }
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
