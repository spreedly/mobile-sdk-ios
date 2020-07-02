//
// Created by Eli Thompson on 5/1/20.
//
import XCTest
@testable import Spreedly

class BankAccountInfoTests: XCTestCase {
    func testCanEncode() throws {
        let creditCard = BankAccountInfo(
                firstName: "Dolly",
                lastName: "Dog",
                bankRoutingNumber: "123456",
                bankAccountNumber: SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111"),
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

    func testCanEncodeWithFullName() throws {
        let creditCard = BankAccountInfo(
                fullName: "Dolly Dog",
                bankRoutingNumber: "123456",
                bankAccountNumber: SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111"),
                bankAccountType: .checking,
                bankAccountHolderType: .personal
        )

        let json = try creditCard.toJson()

        let expected = try """
                           {
                             "full_name" : "Dolly Dog",
                             "bank_routing_number" : "123456",
                             "bank_account_number" : "4111111111111111",
                             "bank_account_type" : "checking",
                             "bank_account_holder_type" : "personal"
                           }
                           """.data(using: .utf8)!.decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testFromShouldClone() {
        let source = BankAccountInfo()
        source.fullName = "Dolly Dog"
        source.firstName = "Dolly"
        source.lastName = "Dog"

        source.bankAccountNumber = SpreedlySecureOpaqueStringBuilder.build(from: "9876543210")
        source.bankRoutingNumber = "021000021"
        source.bankAccountType = .savings
        source.bankAccountHolderType = .business

        source.address.address1 = "123 Fake St"
        source.shippingAddress.address1 = "321 Wall St"

        let sink = BankAccountInfo(fromBankAccount: source)

        XCTAssertEqual(sink.fullName, source.fullName)
        XCTAssertEqual(sink.firstName, source.firstName)
        XCTAssertEqual(sink.lastName, source.lastName)

        XCTAssertNil(sink.bankAccountNumber)
        XCTAssertNil(sink.bankRoutingNumber)
        XCTAssertEqual(sink.bankAccountType, source.bankAccountType)
        XCTAssertEqual(sink.bankAccountHolderType, source.bankAccountHolderType)

        XCTAssertEqual(sink.address, source.address)
        XCTAssertEqual(sink.shippingAddress, source.shippingAddress)
    }
}
