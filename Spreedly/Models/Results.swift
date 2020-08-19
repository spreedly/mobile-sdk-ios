//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation

/// The current state of a gateway, receiver or payment method in the Spreedly database.
public enum StorageState: String {
    case cached
    case retained
    case redacted
}

/// The current state of a gateway, receiver or payment method in the Spreedly database.
@objc(SPRStorageState)
public enum _ObjCStorageState: Int { // swiftlint:disable:this type_name
    case unknown = 0
    case cached
    case retained
    case redacted

    static func from(_ source: StorageState?) -> _ObjCStorageState {
        switch source {
        case .cached: return cached
        case .retained: return retained
        case .redacted: return redacted
        default: return unknown
        }
    }
}

public enum PaymentMethodType: String {
    case creditCard = "credit_card"
    case bankAccount = "bank_account"
    case applePay = "apple_pay"
    case googlePay = "google_pay"
    case thirdPartyToken = "third_party_token"
}

@objc(SPRPaymentMethodType)
public enum _ObjCPaymentMethodType: Int { // swiftlint:disable:this type_name
    case unknown = 0
    case creditCard
    case bankAccount
    case applePay
    case googlePay
    case thirdPartyToken

    public static func from(_ source: PaymentMethodType?) -> _ObjCPaymentMethodType {
        switch source {
        case .creditCard: return creditCard
        case .bankAccount: return bankAccount
        case .applePay: return applePay
        case .googlePay: return googlePay
        case .thirdPartyToken: return thirdPartyToken
        default: return unknown
        }
    }
}

@objc(SPRError)
public class SpreedlyError: NSObject {
    @objc public let key: String
    @objc public let message: String
    @objc public let attribute: String?

    init(from json: [String: Any]) throws {
        key = try json.string(for: "key")
        message = try json.string(for: "message")
        attribute = json.string(optional: "attribute")
    }
}

/// Contains information returned from Spreedly after attempting to create a payment method.
@objc(SPRPaymentMethodResultBase)
public class PaymentMethodResult: NSObject {
    /// The token identifying the newly created payment method in the Spreedly vault.
    @objc public let token: String?
    ///	The storage state of the payment method.
    public let storageState: StorageState?
    /// `true` if this payment method is a test payment method and cannot be used against real gateways or receivers.
    @objc public let test: Bool
    /// The type of this payment method (e.g., `creditCard`, `bankAccount`, `applePay`).
    public let paymentMethodType: PaymentMethodType?

    @objc public let email: String?
    @objc public let firstName: String?
    @objc public let lastName: String?
    @objc public let fullName: String?
    @objc public let company: String?

    @objc public let address: Address?
    @objc public let shippingAddress: Address?
    /// If the payment method is invalid (missing required fields, etc), there will be associated error messages here.
    @objc public let errors: [SpreedlyError]
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

    /// A brief description displayable to the user.
    @objc public var shortDescription: String {
        ""
    }
}

extension PaymentMethodResult {
    @objc(paymentMethodType)
    public var _objCPaymentMethodType: _ObjCPaymentMethodType { // swiftlint:disable:this identifier_name
        _ObjCPaymentMethodType.from(paymentMethodType)
    }

    @objc(storageState)
    public var _objCStorageState: _ObjCStorageState { // swiftlint:disable:this identifier_name
        _ObjCStorageState.from(storageState)
    }
}

/// Contains information returned from Spreedly after attempting to create a credit card payment method.
@objc(SPRCreditCardResult)
public class CreditCardResult: PaymentMethodResult {
    class var paymentMethodType: String {
        "credit_card"
    }

    /// The card brand, e.g., `visa`, `mastercard`.
    @objc public var cardType: String?
    /// The expiration year.
    public var year: Int?
    /// The expiration month.
    public var month: Int?

    /// The last four digits of the credit card number. This can be displayed to the user.
    @objc public var lastFourDigits: String?
    /// The first six digits of the credit card number. This can be displayed to the user.
    @objc public var firstSixDigits: String?
    /// The obscured credit card number, e.g., `XXXX-XXXX-XXXX-4444`.
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

    public override var shortDescription: String {
        let brand = CardBrand.from(spreedlyType: cardType)
        return "\(brand.rawValue.capitalized) \(lastFourDigits ?? "")"
    }

    @objc(year) public var _objCYear: Int { // swiftlint:disable:this identifier_name
        year ?? 0
    }

    @objc(month) public var _objcMonth: Int { // swiftlint:disable:this identifier_name
        month ?? 0
    }
}

/// Contains information returned from Spreedly after attempting to create a bank account payment method.
@objc(SPRBankAccountResult)
public class BankAccountResult: PaymentMethodResult {
    class var paymentMethodType: String {
        "bank_account"
    }

    @objc public var bankName: String?
    /// The type of account. Can be one of `checking` or `savings`.
    @objc public var accountType: BankAccountType = .unknown
    /// The account holder type. Can be one of `business` or `personal`.
    @objc public var accountHolderType: BankAccountHolderType = .unknown
    /// A portion of the routing number. Can be displayed to the user.
    @objc public var routingNumberDisplayDigits: String?
    /// A portion of the account number. Can be displayed to the user.
    @objc public var accountNumberDisplayDigits: String?
    /// The account routing number.
    @objc public var routingNumber: String?
    /// The account number.
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

    public override var shortDescription: String {
        "Bank Account \(accountNumberDisplayDigits ?? "")"
    }
}

/// Contains information returned from Spreedly after attempting to create an Apple Pay payment method.
@objc(SPRApplePayResult)
public class ApplePayResult: CreditCardResult {
    class override var paymentMethodType: String {
        "apple_pay"
    }
}
