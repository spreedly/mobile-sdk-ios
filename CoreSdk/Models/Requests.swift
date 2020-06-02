import PassKit

/// Metadata key-value pairs (limit 25). Keys are limited to 50 characters.
/// Values are limited to 500 characters and cannot contain compounding data types.
public typealias Metadata = [String: Any]

public class PaymentMethodRequestBase {
    public var fullName: String?
    public var firstName: String?
    public var lastName: String?
    public var company: String?

    public var address: Address?
    public var shippingAddress: Address?

    public var retained: Bool?

    init(fullName: String?, firstName: String?, lastName: String?) {
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName

        self.address = Address()
        self.shippingAddress = Address()
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
    public var number: SpreedlySecureOpaqueString?
    public var verificationValue: SpreedlySecureOpaqueString?
    public var year: Int?
    public var month: Int?

    public init() {
        super.init(fullName: nil, firstName: nil, lastName: nil)
    }

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

    /// Copies values from another CreditCardInfo instance
    /// including fullName, firstName, lastName, address,
    /// shippingAddress, and company.
    ///
    /// Card data is not copied.
    /// - Parameter info: The source of the values.
    public init(from info: CreditCardInfo?) {
        super.init(fullName: info?.fullName, firstName: info?.firstName, lastName: info?.lastName)
        address = info?.address
        shippingAddress = info?.shippingAddress
        company = info?.company
    }

    internal override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        try result.setOpaqueString("number", number)
        try result.setOpaqueString("verification_value", verificationValue)
        result["year"] = year
        result["month"] = month

        return result
    }

    internal func toRequestJson(email: String?, metadata: Metadata?) throws -> [String: Any] {
        [
            "payment_method": [
                "email": email ?? "",
                "metadata": metadata ?? Metadata(),
                "credit_card": try self.toJson(),
                "retained": self.retained ?? false
            ]
        ]
    }
}

public enum BankAccountType: String, CaseIterable {
    case checking
    case savings
}

public enum BankAccountHolderType: String, CaseIterable {
    case business
    case personal
}

public class BankAccountInfo: PaymentMethodRequestBase {
    public var bankRoutingNumber: String?
    public var bankAccountNumber: SpreedlySecureOpaqueString?
    public var bankAccountType: BankAccountType?
    public var bankAccountHolderType: BankAccountHolderType?

    public init() {
        super.init(fullName: nil, firstName: nil, lastName: nil)
    }

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

    /// Copies values from another BankAccountInfo instance
    /// including fullName, firstName, lastName, address,
    /// shippingAddress, company, bankAccountType, and
    /// bankAccountHolderType.
    ///
    /// Account data is not copied.
    /// - Parameter info: The source of the values.
    public init(from info: BankAccountInfo?) {
        super.init(fullName: info?.fullName, firstName: info?.firstName, lastName: info?.lastName)
        address = info?.address
        shippingAddress = info?.shippingAddress
        company = info?.company
        bankAccountType = info?.bankAccountType
        bankAccountHolderType = info?.bankAccountHolderType
    }

    internal override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        result.maybeSet("bank_routing_number", bankRoutingNumber)
        try result.setOpaqueString("bank_account_number", bankAccountNumber)
        result.maybeSetEnum("bank_account_type", bankAccountType)
        result.maybeSetEnum("bank_account_holder_type", bankAccountHolderType)

        return result
    }

    internal func toRequestJson(email: String?, metadata: Metadata?) throws -> [String: Any] {
        [
            "payment_method": [
                "email": email ?? "",
                "metadata": metadata ?? Metadata(),
                "bank_account": try self.toJson(),
                "retained": self.retained ?? false
            ]
        ]
    }
}

public class ApplePayInfo: PaymentMethodRequestBase {
    let paymentToken: Data
    public var testCardNumber: String?

    public convenience init(firstName: String, lastName: String, paymentTokenData: Data) {
        self.init(fullName: nil, firstName: firstName, lastName: lastName, paymentTokenData: paymentTokenData)
    }
    public convenience init(firstName: String, lastName: String, payment: PKPayment) {
        self.init(firstName: firstName, lastName: lastName, paymentTokenData: payment.token.paymentData)
    }
    public convenience init(fullName: String, paymentTokenData: Data) {
        self.init(fullName: fullName, firstName: nil, lastName: nil, paymentTokenData: paymentTokenData)
    }
    public convenience init(fullName: String, payment: PKPayment) {
        self.init(fullName: fullName, paymentTokenData: payment.token.paymentData)
    }

    private init(fullName: String?, firstName: String?, lastName: String?, paymentTokenData: Data) {
        self.paymentToken = paymentTokenData
        super.init(fullName: fullName, firstName: firstName, lastName: lastName)
    }

    internal override func toJson() throws -> [String: Any] {
        var result = [String: Any]()

        result["payment_data"] = try paymentToken.decodeJson()
        result.maybeSet("test_card_number", testCardNumber)
        return result
    }

    internal func toRequestJson(email: String?, metadata: Metadata?) throws -> [String: Any] {
        var paymentMethod: [String: Any] = [
            "email": email ?? "",
            "metadata": metadata ?? Metadata(),
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
