//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import Sdk

class CreditCardTests: XCTestCase {
    func testCanEncode() throws {
        var creditCard = CreditCard()
        creditCard.firstName = "Dolly"
        creditCard.lastName = "Dog"
        creditCard.number = "4111111111111111"
        creditCard.month = 12
        creditCard.year = 2022
        creditCard.verificationValue = "999"

        let data = try Coders.encode(entity: creditCard)
        let json = String(data: data, encoding: .utf8)!

        let expected = """
                       {
                         "first_name" : "Dolly",
                         "last_name" : "Dog",
                         "month" : 12,
                         "number" : "4111111111111111",
                         "verification_value" : "999",
                         "year" : 2022
                       }
                       """
        XCTAssertEqual(expected, json)

    }
}

class CreatePaymentMethodRequestTests: XCTestCase {
    func testCanEncode() throws {

        var creditCard = CreditCard()
        creditCard.firstName = "Dolly"
        creditCard.lastName = "Dog"
        creditCard.number = "4111111111111111"
        creditCard.month = 12
        creditCard.year = 2022
        creditCard.verificationValue = "999"

        let request = CreatePaymentMethodRequest(
                email: "dolly@dog.com",
                metadata: ["key": "value"],
                creditCard: creditCard
        )
        let data = try request.wrapToData()
        let json = String(data: data, encoding: .utf8)!

        let expected = """
                       {
                         "payment_method" : {
                           "credit_card" : {
                             "first_name" : "Dolly",
                             "last_name" : "Dog",
                             "month" : 12,
                             "number" : "4111111111111111",
                             "verification_value" : "999",
                             "year" : 2022
                           },
                           "email" : "dolly@dog.com",
                           "metadata" : {
                             "key" : "value"
                           }
                         }
                       }
                       """
        XCTAssertEqual(expected, json)
    }
}
