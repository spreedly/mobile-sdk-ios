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
