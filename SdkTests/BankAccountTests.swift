//
// Created by Eli Thompson on 5/1/20.
//
import XCTest
@testable import Sdk

class BankAccountInfoTests: XCTestCase {
    func testCanEncode() throws {
        let client = createSpreedlyClient(envKey: "", envSecret: "")
        let creditCard = BankAccountInfo(
                firstName: "Dolly",
                lastName: "Dog",
                bankRoutingNumber: "123456",
                bankAccountNumber: client.createSecureString(from: "4111111111111111"),
                bankAccountType: .checking,
                bankAccountHolderType: .personal
        )

        let json = try creditCard.toJson()

        let expected = try """
                           {
                             "first_name" : "Dolly",
                             "last_name" : "Dog",
                             "bank_routing_number" : "123456",
                             "bank_account_number" : "4111111111111111",
                             "bank_account_type" : "checking",
                             "bank_account_holder_type" : "personal"
                           }
                           """.data(using: .utf8)!.decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }
}
