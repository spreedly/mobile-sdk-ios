//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import Spreedly

class CreditCardInfoTests: XCTestCase {
    func initCreditCard() -> CreditCardInfo {
        let info = CreditCardInfo()
        info.firstName = "Dolly"
        info.lastName = "Dog"
        info.number = SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111")
        info.verificationValue = SpreedlySecureOpaqueStringBuilder.build(from: "919")
        info.year = 2029
        info.month = 12
        return info
    }

    func testCanEncode() throws {
        let info = initCreditCard()

        let json = try info.toJson()

        let expected = try """
                           {
                             "first_name" : "Dolly",
                             "last_name" : "Dog",
                             "month" : 12,
                             "number" : "4111111111111111",
                             "verification_value" : "919",
                             "year" : 2029
                           }
                           """.data(using: .utf8)!.spr_decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testCanEncodeWithFullName() throws {
        let creditCard = initCreditCard()
        creditCard.firstName = nil
        creditCard.lastName = nil
        creditCard.fullName = "Dolly Dog"

        let json = try creditCard.toJson()

        let expected = try """
                           {
                             "full_name" : "Dolly Dog",
                             "month" : 12,
                             "number" : "4111111111111111",
                             "verification_value" : "919",
                             "year" : 2029
                           }
                           """.data(using: .utf8)!.spr_decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testCanEncodeWithoutName() throws {
        let creditCard = initCreditCard()
        creditCard.firstName = nil
        creditCard.lastName = nil
        creditCard.fullName = nil
        creditCard.allowBlankName = true

        let json = try creditCard.toJson()

        let expected = try """
                           {
                             "allow_blank_name" : true,
                             "month" : 12,
                             "number" : "4111111111111111",
                             "verification_value" : "919",
                             "year" : 2029
                           }
                           """.data(using: .utf8)!.spr_decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testCanEncodeWithoutNameOrExpiration() throws {
        let creditCard = initCreditCard()
        creditCard.firstName = nil
        creditCard.lastName = nil
        creditCard.fullName = nil
        creditCard.allowBlankName = true
        creditCard.month = nil
        creditCard.year = nil
        creditCard.allowBlankDate = true

        let json = try creditCard.toJson()
        try NSLog(String(data: json.encodeJson(), encoding: .utf8)!)

        let expected = try """
                           {
                             "allow_blank_name" : true,
                             "allow_blank_date": true,
                             "number" : "4111111111111111",
                             "verification_value" : "919",
                           }
                           """.data(using: .utf8)!.spr_decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testFromShouldClone() {
        let source = initCreditCard()
        source.fullName = "Dolly Dog"

        source.company = "Border LLC"

        source.address.address1 = "123 Fake St"
        source.shippingAddress.address1 = "321 Wall St"

        let sink = CreditCardInfo(copyFrom: source)

        XCTAssertEqual(sink.fullName, source.fullName)
        XCTAssertEqual(sink.firstName, source.firstName)
        XCTAssertEqual(sink.lastName, source.lastName)

        XCTAssertNil(sink.number)
        XCTAssertNil(sink.verificationValue)
        XCTAssertEqual(sink.company, source.company)

        XCTAssertEqual(sink.address.address1, "123 Fake St")
        XCTAssertEqual(sink.shippingAddress, source.shippingAddress)
    }
}
