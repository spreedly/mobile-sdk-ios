//
// Created by Stefan Rusek on 10/26/20.
//

import Foundation
import XCTest
@testable import Spreedly
import Spreedly3DS2
@testable import CocoaSample


class ThreeDsTests: XCTestCase {
    public var app: XCUIApplication?

    private var vc: UIViewController?

    override func setUpWithError() throws {
        continueAfterFailure = false
        super.setUp()

        app = XCUIApplication()
        app?.launch()

        app?.buttons["3DS2"].tap()
        XCTAssertTrue(app?.buttons["Begin Purchase"].waitForExistence(timeout: 5) ?? false)
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
    }

    func testInit() throws {
        try ThreeDS.initialize(uiViewController: UIViewController(), test: true)
    }

    func testCreate() throws {
        try testInit()
        let trans = try ThreeDS.createTransactionRequest(cardType: "mastercard")
        let data = trans.serialize()
        print(data)
        XCTAssertNotNil(data)
    }

    func testFritionless() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("0.04")
        app?.buttons["Begin Purchase"].tap()
        let challenged = app?.buttons["Confirmar"].waitForExistence(timeout: 60) ?? false
        try XCTSkipIf(challenged, "This test only works sometimes.")
        XCTAssertTrue(app?.staticTexts["frictionless success"].waitForExistence(timeout: 30) ?? false)
    }

    func testSuccess() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("1000.00")
        app?.buttons["Begin Purchase"].tap()
        XCTAssertTrue(app?.buttons["Confirmar"].waitForExistence(timeout: 60) ?? false)
        app?.textFields.element(boundBy: (app?.textFields.count ?? 1) - 1).clearAndText("123456")
        app?.buttons["Confirmar"].tap()
        XCTAssertTrue(app?.staticTexts["success: Y"].waitForExistence(timeout: 30) ?? false)
    }

    func testCancel() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("1000.00")
        app?.buttons["Begin Purchase"].tap()
        XCTAssertTrue(app?.buttons["Confirmar"].waitForExistence(timeout: 60) ?? false)
        app?.buttons["CANCEL"].tap()
        XCTAssertTrue(app?.staticTexts["cancelled"].waitForExistence(timeout: 30) ?? false)
    }

    func testFailedNoAuth1() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("99.96")
        app?.buttons["Begin Purchase"].tap()
        XCTAssertTrue(app?.staticTexts["error: runtimeError(message: \"not_authenticated\")"].waitForExistence(timeout: 30) ?? false)
    }

    func testFailedNoAuth2() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("99.97")
        app?.buttons["Begin Purchase"].tap()
        XCTAssertTrue(app?.staticTexts["error: runtimeError(message: \"not_authenticated\")"].waitForExistence(timeout: 30) ?? false)
    }

    func testFailedDenied() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("99.98")
        app?.buttons["Begin Purchase"].tap()
        XCTAssertTrue(app?.staticTexts["error: runtimeError(message: \"not_authenticated\")"].waitForExistence(timeout: 30) ?? false)
    }

    func testFailedRejected() throws {
        app?.textFields.element(boundBy: 0).clearAndText("5555555555554444")
        app?.textFields.element(boundBy: 1).clearAndText("99.99")
        app?.buttons["Begin Purchase"].tap()
        XCTAssertTrue(app?.staticTexts["error: runtimeError(message: \"not_authenticated\")"].waitForExistence(timeout: 30) ?? false)
    }

    func startForTransaction(_ card: String, _ amount: Double) throws -> [String: Any] {
        let client = Helpers.createClient() as! SpreedlyClientImpl
        let info = Helpers.initCreditCard()
        info.number?.clear()
        info.number?.append(card)
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
        let cardType = transaction.creditCard!.cardType!

        try testInit()
        let _3ds2 = try ThreeDS.createTransactionRequest(cardType: cardType)

        let session = client.session(authenticated: true)
        var request = URLRequest(url: client.authenticatedPurchaseUrl("BkXcmxRDv8gtMUwu5Buzb4ZbqGe"))
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "transaction": [
                "payment_method_token": token,
                "amount": amount,
                "currency_code": "USD",
                "redirect_url": "http://test.com/",
                "callback_url": "http://test.com/",
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

        let auth = json?.object(optional: "transaction")?.object(optional: "sca_authentication")
        XCTAssertNotNil(auth?.string(optional: "xid"))
        XCTAssertNotNil(auth?.string(optional: "acs_transaction_id"))
        XCTAssertNotNil(auth?.string(optional: "acs_reference_number"))
        XCTAssertNotNil(auth?.string(optional: "acs_signed_content"))

        return auth!
    }



}


extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }

        tap()
        typeText(deleteString)
    }
    
    func clearAndText(_ text: String) {
        clearText()
        tap()
        typeText(text)
    }
}
