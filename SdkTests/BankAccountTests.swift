//
// Created by Eli Thompson on 5/1/20.
//
import XCTest
@testable import Sdk

class BankAccountTests: XCTestCase {

    let createBankAccountResponse = """
                                    {
                                      "payment_method" : {
                                        "bank_account" : {
                                          "bank_account_holder_type" : "personal",
                                          "bank_account_number" : "9876543210",
                                          "bank_account_type" : "checking",
                                          "bank_routing_number" : "021000021",
                                          "first_name" : "Dolly",
                                          "last_name" : "Dog"
                                        },
                                        "data" : {
                                          "data-key" : "data-value"
                                        },
                                        "email" : "dolly@dog.com",
                                        "metadata" : {
                                          "key" : "value"
                                        }
                                      }
                                    }
                                    """

    func testCanEncode() throws {
        let account = BankAccount()
        account.firstName = "Dolly"
        account.lastName = "Dog"
        account.bankRoutingNumber = "021000021"
        account.bankAccountNumber = "9876543210"
        account.bankAccountType = "checking"
        account.bankAccountHolderType = "personal"

        let request = CreateBankAccountPaymentMethodRequest(
                bankAccount: account,
                email: "dolly@dog.com",
                data: ["data-key": "data-value"],
                metadata: ["key": "value"]
        )

        let jsonData = try request.wrapToData()
        let actualJson = String(data: jsonData, encoding: .utf8)!

        XCTAssertEqual(createBankAccountResponse, actualJson)
    }
}
