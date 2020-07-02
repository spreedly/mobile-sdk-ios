//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import CoreSdk

class CreditCardInfoTests: XCTestCase {
    func testCanEncode() throws {
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111"),
                verificationValue: SpreedlySecureOpaqueStringBuilder.build(from: "919"),
                year: 2029,
                month: 12
        )

        let json = try creditCard.toJson()

        let expected = try """
                           {
                             "first_name" : "Dolly",
                             "last_name" : "Dog",
                             "month" : 12,
                             "number" : "4111111111111111",
                             "verification_value" : "919",
                             "year" : 2029
                           }
                           """.data(using: .utf8)!.decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testCanEncodeWithFullName() throws {
        let creditCard = CreditCardInfo(
                fullName: "Dolly Dog",
                number: SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111"),
                verificationValue: SpreedlySecureOpaqueStringBuilder.build(from: "919"),
                year: 2029,
                month: 12
        )

        let json = try creditCard.toJson()

        let expected = try """
                           {
                             "full_name" : "Dolly Dog",
                             "month" : 12,
                             "number" : "4111111111111111",
                             "verification_value" : "919",
                             "year" : 2029
                           }
                           """.data(using: .utf8)!.decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testFromShouldClone() {
        let source = CreditCardInfo()
        source.fullName = "Dolly Dog"
        source.firstName = "Dolly"
        source.lastName = "Dog"

        source.number = SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111")
        source.verificationValue = SpreedlySecureOpaqueStringBuilder.build(from: "123")
        source.company = "Border LLC"

        source.address.address1 = "123 Fake St"
        source.shippingAddress.address1 = "321 Wall St"

        let sink = CreditCardInfo(fromCard: source)

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
