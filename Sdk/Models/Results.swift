//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation

public enum StorageState: String, Codable {
    case cached
    case retained
    case redacted
}

public enum PaymentMethodType: String, Codable {
    case creditCard = "credit_card"
    case bankAccount = "bank_account"
    case applePay = "apple_pay"
    case googlePay = "google_pay"
    case thirdPartyToken = "third_party_token"
}

public struct SpreedlyError: Decodable {
    public let key: String
    public let message: String
    public let attribute: String?

    init(from json: [String: Any]) throws {
        key = try json.string(for: "key")
        message = try json.string(for: "message")
        attribute = json.string(optional: "attribute")
    }
}

public class PaymentMethodResultBase {
    public let token: String?
    public let storageState: StorageState?
    public let test: Bool
    public let paymentMethodType: PaymentMethodType?

    public let email: String?
    public let firstName: String?
    public let lastName: String?
    public let fullName: String?

    public let address: Address?
    public let shippingAddress: Address?
    public let errors: [SpreedlyError]

    required init(from json: [String: Any]) {
        token = json.string(optional: "token")
        storageState = json.enumValue(optional: "storage_state")
        test = json.bool(optional: "test") ?? false
        paymentMethodType = json.enumValue(optional: "payment_method_type")

        email = json.string(optional: "email")
        firstName = json.string(optional: "first_name")
        lastName = json.string(optional: "last_name")
        fullName = json.string(optional: "full_name")

        address = Address(from: json, as: .billing)
        shippingAddress = Address(from: json, as: .shipping)
        errors = json.objectList(optional: "errors", { json in try SpreedlyError(from: json) }) ?? []
    }
}

public class CreditCardResult: PaymentMethodResultBase {
    public var cardType: String?
    public var year: Int?
    public var month: Int?

    public var lastFourDigits: String?
    public var firstSixDigits: String?
    public var number: String?

    public var eligibleForCardUpdater: Bool?
    public var callbackUrl: String?
    public var fingerprint: String?

    required init(from json: [String: Any]) {
        cardType = json.string(optional: "card_type")
        year = json.int(optional: "year")
        month = json.int(optional: "month")

        lastFourDigits = json.string(optional: "last_four_digits")
        firstSixDigits = json.string(optional: "first_six_digits")
        number = json.string(optional: "number")

        eligibleForCardUpdater = json.bool(optional: "eligible_for_card_updater")
        callbackUrl = json.string(optional: "callback_url")
        fingerprint = json.string(optional: "fingerprint")

        super.init(from: json)
    }
}

public class BankAccountResult: PaymentMethodResultBase {
    public var bankName: String?
    public var accountType: BankAccountType?
    public var accountHolderType: BankAccountHolderType?
    public var routingNumberDisplayDigits: String?
    public var accountNumberDisplayDigits: String?
    public var routingNumber: String?
    public var accountNumber: String?

    required init(from json: [String: Any]) {
        bankName = json.string(optional: "bank_name")
        accountType = json.enumValue(optional: "account_type")
        accountHolderType = json.enumValue(optional: "account_holder_type")
        routingNumberDisplayDigits = json.string(optional: "routing_number_display_digits")
        accountNumberDisplayDigits = json.string(optional: "account_number_display_digits")
        routingNumber = json.string(optional: "routing_number")
        accountNumber = json.string(optional: "account_number")

        super.init(from: json)
    }
}

public class ApplePayResult: CreditCardResult {
}
