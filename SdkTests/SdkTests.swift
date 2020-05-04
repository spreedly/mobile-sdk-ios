//
//  SdkTests.swift
//  SdkTests
//
//  Created by Eli Thompson on 4/23/20.
//  Copyright © 2020 Spreedly. All rights reserved.
//

import XCTest
@testable import Sdk

class SdkTests: XCTestCase {

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
        let jsonData = try request.wrapToData()

        let actualJson = String(data: jsonData, encoding: .utf8)!
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
        XCTAssertEqual(expected, actualJson)
    }
}

class UtilDecodeTests: XCTestCase {
    let showCreditCardResponse = """
                                 {
                                   "payment_method": {
                                     "token": "1rpKvP8zOUhj4Y9EDrIoIYQzzD5",
                                     "created_at": "2017-06-26T17:04:38Z",
                                     "updated_at": "2018-11-07T15:19:09Z",
                                     "email": "joey@example.com",
                                     "data": {
                                       "my_payment_method_identifier": "448",
                                       "extra_stuff": {
                                         "some_other_things": "Can be anything really"
                                       }
                                     },
                                     "storage_state": "retained",
                                     "test": true,
                                     "metadata": {
                                       "key": "string value",
                                       "another_key": 123,
                                       "final_key": true
                                     },
                                     "last_four_digits": "1111",
                                     "first_six_digits": "411111",
                                     "card_type": "visa",
                                     "first_name": "Newfirst",
                                     "last_name": "Newlast",
                                     "month": 3,
                                     "year": 2032,
                                     "address1": null,
                                     "address2": null,
                                     "city": null,
                                     "state": null,
                                     "zip": null,
                                     "country": null,
                                     "phone_number": null,
                                     "company": null,
                                     "full_name": "Newfirst Newlast",
                                     "eligible_for_card_updater": true,
                                     "shipping_address1": null,
                                     "shipping_address2": null,
                                     "shipping_city": null,
                                     "shipping_state": null,
                                     "shipping_zip": null,
                                     "shipping_country": null,
                                     "shipping_phone_number": null,
                                     "payment_method_type": "credit_card",
                                     "errors": [

                                     ],
                                     "fingerprint": "e3cef43464fc832f6e04f187df25af497994",
                                     "verification_value": "XXX",
                                     "number": "XXXX-XXXX-XXXX-1111"
                                   }
                                 }
                                 """

    func testCanDecodeShowCreditCardResponse() throws {
        let jsonData = showCreditCardResponse.data(using: .utf8)!
        let codingData: CreditCard.CodingData = try Coders.decode(data: jsonData)
        let creditCard = codingData.paymentMethod

        XCTAssertEqual("1rpKvP8zOUhj4Y9EDrIoIYQzzD5", creditCard.token, "String decodable")
        XCTAssertNil(creditCard.address1, "Nil decodable")

        let expectedDate = DateComponents(
                calendar: Calendar.current,
                timeZone: TimeZone(abbreviation: "UTC"),
                year: 2017,
                month: 06,
                day: 26,
                hour: 17,
                minute: 04,
                second: 38
        ).date
        XCTAssertEqual(expectedDate, creditCard.createdAt, "Date decodable")
    }
}
