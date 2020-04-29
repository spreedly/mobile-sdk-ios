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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        var cc = CreditCard()
        cc.firstName = "Dolly"
        cc.lastName = "Dog"
        cc.number = "4111111111111111"
        cc.month = "12"
        cc.year = "2022"
        cc.verificationValue = "999"

        let pm = PaymentMethod(creditCard: cc, email: "dolly@dog.com", metadata: ["key": "value"])
        let r = Sdk.CreateCreditCardRequest(paymentMethod: pm)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        var jsonString: String
        do {
            let jsonData = try encoder.encode(r)
            jsonString = String(data: jsonData, encoding: .utf8)!
        } catch {
            XCTFail("\(error)")
            return
        }

        let expected = """
{
  "payment_method" : {
    "email" : "dolly@dog.com",
    "credit_card" : {
      "number" : "4111111111111111",
      "last_name" : "Dog",
      "verification_value" : "999",
      "month" : "12",
      "first_name" : "Dolly",
      "year" : "2022"
    },
    "metadata" : {
      "key" : "value"
    }
  }
}
"""
        XCTAssertEqual(expected, jsonString)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class UtilDecodeTests: XCTestCase {
    func testCanDecodeShowCreditCardResponse() throws {
        let json = """
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
        let jsonData = json.data(using: .utf8)!
        let u = Util(envKey: "", envSecret: "")
        let entity: ShowCreditCardResponse = try u.decode(data: jsonData)

        XCTAssertEqual("1rpKvP8zOUhj4Y9EDrIoIYQzzD5", entity.paymentMethod.token, "String decodable")
        XCTAssertNil(entity.paymentMethod.address1, "Nil decodable")

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
        XCTAssertEqual(expectedDate, entity.paymentMethod.createdAt, "Date decodable")
    }
}
