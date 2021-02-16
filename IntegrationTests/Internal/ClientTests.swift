//
// Created by Stefan Rusek on 5/6/20.
//

import XCTest
import Spreedly

class ClientTests: XCTestCase {
    /// The API responds with a 401 and a valid JSON response, the client should return the decoded JSON response.
    /// If trans.message is null, then the client should populate it with the first error message from trans.errors
    func testEmptyKey() throws {
        let config = ClientConfiguration(envKey: "")
        let client = ClientFactory.create(with: config)
        let info = Helpers.initCreditCard()
        info.retained = true
        let resp = client.createPaymentMethodFrom(creditCard: info)
        let trans = try resp.assertResult(self)

        XCTAssertFalse(trans.succeeded)
        XCTAssertEqual(trans.errors?.count, 1)
        let message = [
            "Unable to authenticate using the given environment_key and access_token.",
            "  Please check your credentials."
        ].joined(separator: "")

        XCTAssertEqual(trans.errors?[0].message, message)
        XCTAssertEqual(trans.message, message)
    }
}
