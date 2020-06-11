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

public class PaymentMethodResultBase: NSObject {
    @objc public let token: String?
    public let storageState: StorageState?
    public let test: Bool
    public let paymentMethodType: PaymentMethodType?

    @objc public let email: String?
    @objc public let firstName: String?
    @objc public let lastName: String?
    @objc public let fullName: String?
    @objc public let company: String?

    @objc public let address: Address?
    @objc public let shippingAddress: Address?
    public let errors: [SpreedlyError]
    @objc public let metadata: Metadata?

    required init(from json: [String: Any]) {
        token = json.string(optional: "token")
        storageState = json.enumValue(optional: "storage_state")
        test = json.bool(optional: "test") ?? false
        paymentMethodType = json.enumValue(optional: "payment_method_type")

        email = json.string(optional: "email")
        firstName = json.string(optional: "first_name")
        lastName = json.string(optional: "last_name")
        fullName = json.string(optional: "full_name")
        company = json.string(optional: "company")

        address = Address(from: json, as: .billing)
        shippingAddress = Address(from: json, as: .shipping)
        errors = json.objectList(optional: "errors", { json in try SpreedlyError(from: json) }) ?? []
        metadata = json.object(optional: "metadata")
    }
}

@objc(SPRCreditCardResult)
public class CreditCardResult: PaymentMethodResultBase {
    class var paymentMethodType: String {
        "credit_card"
    }

    @objc public var cardType: String?
    public var year: Int?
    public var month: Int?

    @objc public var lastFourDigits: String?
    @objc public var firstSixDigits: String?
    @objc public var number: String?

    public var eligibleForCardUpdater: Bool?
    @objc public var callbackUrl: String?
    @objc public var fingerprint: String?

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

    @objc(year) public var _objCYear: Int {
        year ?? 0
    }

    @objc(month) public var _objcMonth: Int {
        month ?? 0
    }
}

@objc(SPRBankAccountResult)
public class BankAccountResult: PaymentMethodResultBase {
    class var paymentMethodType: String {
        "bank_account"
    }

    @objc public var bankName: String?
    @objc public var accountType: BankAccountType = .unknown
    @objc public var accountHolderType: BankAccountHolderType = .unknown
    @objc public var routingNumberDisplayDigits: String?
    @objc public var accountNumberDisplayDigits: String?
    @objc public var routingNumber: String?
    @objc public var accountNumber: String?

    required init(from json: [String: Any]) {
        bankName = json.string(optional: "bank_name")
        accountType = BankAccountType.from(json.string(optional: "account_type"))
        accountHolderType = BankAccountHolderType.from(json.string(optional: "account_holder_type"))
        routingNumberDisplayDigits = json.string(optional: "routing_number_display_digits")
        accountNumberDisplayDigits = json.string(optional: "account_number_display_digits")
        routingNumber = json.string(optional: "routing_number")
        accountNumber = json.string(optional: "account_number")

        super.init(from: json)
    }
}

public class ApplePayResult: CreditCardResult {
    class override var paymentMethodType: String {
        "apple_pay"
    }
}
