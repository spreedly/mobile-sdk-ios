//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import CoreSdk

class CreditCardInfoTests: XCTestCase {
    func testCanEncode() throws {
        let client = createSpreedlyClient(envKey: "", envSecret: "")
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: "919"),
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
        let client = createSpreedlyClient(envKey: "", envSecret: "")
        let creditCard = CreditCardInfo(
                fullName: "Dolly Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: "919"),
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
}
