//
// Created by Stefan Rusek on 10/26/20.
//

import Foundation
import XCTest
@testable import Spreedly


class ThreeDsTests: XCTestCase {
    func testInit() throws {
        try SpreedlyThreeDS.initialize(uiViewController: UIViewController(), locale: nil)
    }

    func testCreate() throws {
        try SpreedlyThreeDS.initialize(uiViewController: UIViewController(), locale: nil)
        let trans = try SpreedlyThreeDS.createTransactionRequest()
        let data = trans.serialize()
        print(data)
        XCTAssertNotNil(data)
    }

    func testCanCreateFullCreditCard() throws {
        let client = Helpers.createClient() as! SpreedlyClientImpl
        let info = Helpers.initCreditCard()
        info.address = Helpers.buildAddress()
        info.shippingAddress = Helpers.buildShippingAddress()
        info.email = "dolly@dog.com"
        info.metadata = [
            "stringKey": "correcthorsebatterystaple",
            "intKey": 42,
            "doubleKey": 3.14,
            "boolKey": false
        ]

        let promise = client.createPaymentMethodFrom(creditCard: info)
        let transaction = try promise.assertResult(self)
        let token = transaction.creditCard!.token!

        try testInit()
        let _3ds2 = try SpreedlyThreeDS.createTransactionRequest()

        let session = client.session(authenticated: true)
        var request = URLRequest(url: client.authenticatedPurchaseUrl("BkXcmxRDv8gtMUwu5Buzb4ZbqGe"))
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "transaction": [
                "payment_method_token": token,
                "amount": 3001,
                "currency_code": "USD",
                "redirect_url": "http://test.com/",
                "callback_url": "http://test.com/",
                "three_ds_version": "2",
                "device_info": _3ds2.serialize(),
                "channel": "app",
                "sca_provider_key": "M8k0FisOKdAmDgcQeIKlHE7R1Nf"
            ] as [String: Any]
        ] as [String: Any])

        var json: [String: Any]?
        let expectation = self.expectation(description: "purchase call")
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                print(String(data: data, encoding: .utf8) ?? "bad utf8")
            }
            if let error = error {
                XCTFail("\(error)")
            } else if json == nil {
                XCTFail()
            }
            expectation.fulfill()
        }
        task.resume()
        self.wait(for: [expectation], timeout: 20.0)
        print("Request")
        print((try? JSONSerialization.jsonObject(with: request.httpBody!)) ?? [:])
        print("Response")
        print(json ?? [:])

        XCTAssertEqual(try json?.object(for: "transaction").string(for: "required_action"), "app_challenge")
    }

}
