//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import Sdk

class CreditCardInfoTests: XCTestCase {
    func testCanEncode() throws {
        let client = createSpreedlyClient(env: "", secret: "")
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: "919"),
                year: 2029,
                month: 12
        )

        let data = try JSONSerialization.data(
                withJSONObject: creditCard.toJson(),
                options: [.sortedKeys, .prettyPrinted]
        )
        let json = String(data: data, encoding: .utf8)!

        let expected = """
                       {
                         "first_name" : "Dolly",
                         "last_name" : "Dog",
                         "month" : 12,
                         "number" : "4111111111111111",
                         "verification_value" : "919",
                         "year" : 2029
                       }
                       """
        XCTAssertEqual(expected, json)
    }
}

class CreatePaymentMethodRequestTests: XCTestCase {
    func testCanEncode() throws {

        let client = createSpreedlyClient(env: "", secret: "")
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: "919"),
                year: 2029,
                month: 12
        )

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
                             "verification_value" : "919",
                             "year" : 2029
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

class CreditCardTransactionCreatedTests: XCTestCase {
    let createCreditCardResponse = """
                                   {
                                     "transaction": {
                                       "token": "L46gdNQunedFoor9ySRJfgz7RAk",
                                       "created_at": "2020-02-11T20:49:32Z",
                                       "updated_at": "2020-02-11T20:49:32Z",
                                       "succeeded": true,
                                       "transaction_type": "AddPaymentMethod",
                                       "retained": false,
                                       "state": "succeeded",
                                       "message_key": "messages.transaction_succeeded",
                                       "message": "Succeeded!",
                                       "payment_method": {
                                         "token": "VBVmxAmSDxmc7AjUGi7ViUf9avm",
                                         "created_at": "2020-02-11T20:49:32Z",
                                         "updated_at": "2020-02-11T20:49:32Z",
                                         "email": "joey@example.com",
                                         "storage_state": "cached",
                                         "test": true,
                                         "metadata": {
                                           "key": "string value",
                                           "another_key": 123,
                                           "final_key": true
                                         },
                                         "callback_url": null,
                                         "last_four_digits": "4444",
                                         "first_six_digits": "555555",
                                         "card_type": "master",
                                         "first_name": "Joe",
                                         "last_name": "Jones",
                                         "month": 3,
                                         "year": 2032,
                                         "address1": "33 Lane Road",
                                         "address2": "Apartment 4",
                                         "city": "Wanaque",
                                         "state": "NJ",
                                         "zip": "31331",
                                         "country": "US",
                                         "phone_number": "919.331.3313",
                                         "company": "Acme Inc.",
                                         "full_name": "Joe Jones",
                                         "eligible_for_card_updater": true,
                                         "shipping_address1": "33 Lane Road",
                                         "shipping_address2": "Apartment 4",
                                         "shipping_city": "Wanaque",
                                         "shipping_state": "NJ",
                                         "shipping_zip": "31331",
                                         "shipping_country": "US",
                                         "shipping_phone_number": "919.331.3313",
                                         "payment_method_type": "credit_card",
                                         "errors": [

                                         ],
                                         "fingerprint": "b5fe350d5135ab64a8f3c1097fadefd9effb",
                                         "verification_value": "XXX",
                                         "number": "XXXX-XXXX-XXXX-4444"
                                       }
                                     }
                                   }
                                   """

    func testCanDecode() throws {
        let data = createCreditCardResponse.data(using: .utf8)!
        let transaction = try Transaction<CreditCardResult>.unwrapFrom(data: data)

        XCTAssertEqual("L46gdNQunedFoor9ySRJfgz7RAk", transaction.token, "can decode transaction token")
        XCTAssert(transaction.succeeded, "can decode boolean")

        let creditCard = transaction.paymentMethod!
        XCTAssertEqual("VBVmxAmSDxmc7AjUGi7ViUf9avm", creditCard.token, "can decode credit card token")
        XCTAssertNil(creditCard.callbackUrl, "can decode nil")
    }

    let errorResponse = """
                        {
                            "errors": [{
                                "key": "errors.account_inactive",
                                "message": "Your environment (A###############l) has not been activated for real transactions with real payment methods. If you're using a Test Gateway you can *ONLY* use Test payment methods - ( https://docs.spreedly.com/test-data). All other credit card numbers are considered real credit cards; real credit cards are not allowed when using a Test Gateway."
                            }]
                        }
                        """

    func testCanDecodeErrorResponses() throws {
        let data = errorResponse.data(using: .utf8)!
        let transaction = try Transaction<CreditCardResult>.unwrapFrom(data: data)

        XCTAssertNil(transaction.paymentMethod)
        XCTAssertEqual(transaction.errors?.count, 1)
        let err = transaction.errors![0]
        XCTAssertEqual("errors.account_inactive", err.key)
        XCTAssertEqual(346, err.message.count)
        XCTAssertNil(err.attribute)
    }
}

class CreateRecacheRequestTests: XCTestCase {
    func testCanEncode() throws {
        var creditCard = CreditCard()
        creditCard.verificationValue = "919"

        let request = CreateRecacheRequest(creditCard: creditCard)

        let data = try request.wrapToData()
        let json = String(data: data, encoding: .utf8)!

        let expected = """
                       {
                         "payment_method" : {
                           "credit_card" : {
                             "verification_value" : "919"
                           }
                         }
                       }
                       """
        XCTAssertEqual(expected, json)
    }
}
