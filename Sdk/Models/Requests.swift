import PassKit

public class PaymentMethodRequestBase {
    public let fullName: String?
    public let firstName: String?
    public let lastName: String?
    public var company: String?

    public var address: Address?
    public var shippingAddress: Address?

    public var retained: Bool?

    init(fullName: String?, firstName: String?, lastName: String?) {
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
    }

    internal func toJson() throws -> [String: Any] {
        var result: [String: Any] = [:]
        result.maybeSet("full_name", fullName)
        result.maybeSet("first_name", firstName)
        result.maybeSet("last_name", lastName)
        result.maybeSet("company", company)

        self.address?.toJson(&result, .billing)
        self.shippingAddress?.toJson(&result, .shipping)

        return result
    }
}

public class CreditCardInfo: PaymentMethodRequestBase {
    public let number: SpreedlySecureOpaqueString
    public let verificationValue: SpreedlySecureOpaqueString
    public let year: Int
    public let month: Int

    public init(
            fullName: String,
            number: SpreedlySecureOpaqueString,
            verificationValue: SpreedlySecureOpaqueString,
            year: Int,
            month: Int
    ) {
        self.number = number
        self.verificationValue = verificationValue
        self.year = year
        self.month = month
        super.init(fullName: fullName, firstName: nil, lastName: nil)
    }

    public init(
            firstName: String,
            lastName: String,
            number: SpreedlySecureOpaqueString,
            verificationValue: SpreedlySecureOpaqueString,
            year: Int,
            month: Int
    ) {
        self.number = number
        self.verificationValue = verificationValue
        self.year = year
        self.month = month
        super.init(fullName: nil, firstName: firstName, lastName: lastName)
    }

    internal override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        try result.setOpaqueString("number", self.number)
        try result.setOpaqueString("verification_value", self.verificationValue)
        result["year"] = self.year
        result["month"] = self.month

        return result
    }

    internal func toRequestJson(email: String?, metadata: [String: String]?) throws -> [String: Any] {
        [
            "payment_method": [
                "email": email ?? "",
                "metadata": metadata ?? [:],
                "credit_card": try self.toJson(),
                "retained": self.retained ?? false
            ]
        ]
    }
}

public enum BankAccountType: String {
    case checking
    case savings
}

public enum BankAccountHolderType: String {
    case business
    case personal
}

public class BankAccountInfo: PaymentMethodRequestBase {
    public let bankRoutingNumber: String
    public let bankAccountNumber: SpreedlySecureOpaqueString
    public let bankAccountType: BankAccountType
    public let bankAccountHolderType: BankAccountHolderType

    public init(
            fullName: String,
            bankRoutingNumber: String,
            bankAccountNumber: SpreedlySecureOpaqueString,
            bankAccountType: BankAccountType,
            bankAccountHolderType: BankAccountHolderType
    ) {
        self.bankRoutingNumber = bankRoutingNumber
        self.bankAccountNumber = bankAccountNumber
        self.bankAccountType = bankAccountType
        self.bankAccountHolderType = bankAccountHolderType
        super.init(fullName: fullName, firstName: nil, lastName: nil)
    }

    public init(
            firstName: String,
            lastName: String,
            bankRoutingNumber: String,
            bankAccountNumber: SpreedlySecureOpaqueString,
            bankAccountType: BankAccountType,
            bankAccountHolderType: BankAccountHolderType
    ) {
        self.bankRoutingNumber = bankRoutingNumber
        self.bankAccountNumber = bankAccountNumber
        self.bankAccountType = bankAccountType
        self.bankAccountHolderType = bankAccountHolderType
        super.init(fullName: nil, firstName: firstName, lastName: lastName)
    }

    internal override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        result.maybeSet("bank_routing_number", bankRoutingNumber)
        try result.setOpaqueString("bank_account_number", bankAccountNumber)
        result.maybeSetEnum("bank_account_type", bankAccountType)
        result.maybeSetEnum("bank_account_holder_type", bankAccountHolderType)

        return result
    }

    internal func toRequestJson(email: String?, metadata: [String: String]?) throws -> [String: Any] {
        [
            "payment_method": [
                "email": email ?? "",
                "metadata": metadata ?? [:],
                "bank_account": try self.toJson(),
                "retained": self.retained ?? false
            ]
        ]
    }
}

public class ApplePayInfo: PaymentMethodRequestBase {
    let paymentToken: Data
    public var testCardNumber: String?

    public init(firstName: String, lastName: String, paymentTokenData: Data) {
        self.paymentToken = paymentTokenData
        super.init(fullName: nil, firstName: firstName, lastName: lastName)
    }
    public convenience init(firstName: String, lastName: String, payment: PKPayment) {
        self.init(firstName: firstName, lastName: lastName, paymentTokenData: payment.token.paymentData)
    }

    internal override func toJson() throws -> [String: Any] {
        var result = [String: Any]()

        result["payment_data"] = try paymentToken.decodeJson()
        result.maybeSet("test_card_number", testCardNumber)
        return result
    }

    internal func toRequestJson(email: String?, metadata: [String: String]?) throws -> [String: Any] {
        var paymentMethod: [String: Any] = [
            "email": email ?? "",
            "metadata": metadata ?? [:],
            "apple_pay": try self.toJson(),
            "retained": self.retained ?? false
        ]

        // The Apple Pay endpoint expects the person-specific and address
        // information up at the payment_method level unlike the other
        // types of payment methods.
        paymentMethod.maybeSet("first_name", self.firstName)
        paymentMethod.maybeSet("last_name", self.lastName)
        paymentMethod.maybeSet("full_name", self.fullName)
        paymentMethod.maybeSet("company", self.company)

        if let address = self.address {
            address.toJson(&paymentMethod, .billing)
        }
        if let shipping = self.shippingAddress {
            shipping.toJson(&paymentMethod, .shipping)
        }

        return [
            "payment_method": paymentMethod
        ]
    }
}
