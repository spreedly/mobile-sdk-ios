import PassKit

/// Metadata key-value pairs (limit 25). Keys are limited to 50 characters.
/// Values are limited to 500 characters and cannot contain compounding data types.
public typealias Metadata = [String: Any]

public class PaymentMethodRequestBase: NSObject {
    @objc public var email: String?
    @objc public var metadata: Metadata?

    @objc public var fullName: String?
    @objc public var firstName: String?
    @objc public var lastName: String?
    @objc public var company: String?

    @objc public var address: Address
    @objc public var shippingAddress: Address

    /// When true, an authenticated request must be sent to the server including both the
    /// environment key and secret.
    public var retained: Bool?

    init(fullName: String?, firstName: String?, lastName: String?) {
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName

        self.address = Address()
        self.shippingAddress = Address()
    }

    public init(from info: PaymentMethodRequestBase?) {
        fullName = info?.fullName
        firstName = info?.firstName
        lastName = info?.lastName
        company = info?.company

        email = info?.email
        metadata = info?.metadata

        if let address = info?.address {
            self.address = Address(from: address)
        } else {
            self.address = Address()
        }

        if let shippingAddress = info?.shippingAddress {
            self.shippingAddress = Address(from: shippingAddress)
        } else {
            self.shippingAddress = Address()
        }
    }

    internal func toJson() throws -> [String: Any] {
        var result = [String: Any]()
        result.maybeSet("full_name", fullName)
        result.maybeSet("first_name", firstName)
        result.maybeSet("last_name", lastName)
        result.maybeSet("company", company)

        result.merge(address.toJson(type: .billing), uniquingKeysWith: { $1 })
        result.merge(shippingAddress.toJson(type: .shipping), uniquingKeysWith: { $1 })

        return result
    }

    internal func toRequestJson() throws -> [String: Any] {
        fatalError("must be overridden")
    }
}

public class CreditCardInfo: PaymentMethodRequestBase {
    @objc public var number: SpreedlySecureOpaqueString?
    @objc public var verificationValue: SpreedlySecureOpaqueString?
    public var year: Int?
    public var month: Int?

    @objc public init() {
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

    @objc
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

    public init(fromInfo info: PaymentMethodRequestBase?) {
        super.init(from: info)
    }

    /// Copies values from another CreditCardInfo instance
    /// including fullName, firstName, lastName, address,
    /// shippingAddress, company, email, and metadata.
    ///
    /// Card data is not copied.
    /// - Parameter info: The source of the values.
    public convenience init(fromCard info: CreditCardInfo?) {
        self.init(fromInfo: info)
    }

    override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        try result.setOpaqueString("number", number)
        try result.setOpaqueString("verification_value", verificationValue)
        result["year"] = year
        result["month"] = month

        return result
    }

    override func toRequestJson() throws -> [String: Any] {
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

extension CreditCardInfo {
    @objc(year) public var _objCYear: Int { // swiftlint:disable:this identifier_name
        get {
            year ?? 0
        }
        set {
            self.year = newValue
        }
    }

    @objc(month) public var _objCMonth: Int { // swiftlint:disable:this identifier_name
        get {
            month ?? 0
        }
        set {
            self.month = newValue
        }
    }
}

@objc public enum BankAccountType: Int, CaseIterable {
    case unknown
    case checking
    case savings

    public var stringValue: String? {
        switch self {
        case .unknown: return nil
        case .checking: return "checking"
        case .savings: return "savings"
        }
    }

    static func from(_ string: String?) -> BankAccountType {
        switch string {
        case "checking": return .checking
        case "savings": return .savings
        default: return .unknown
        }
    }
}

@objc public enum BankAccountHolderType: Int, CaseIterable {
    case unknown
    case business
    case personal

    public var stringValue: String? {
        switch self {
        case .unknown: return nil
        case .business: return "business"
        case .personal: return "personal"
        }
    }

    static func from(_ string: String?) -> BankAccountHolderType {
        switch string {
        case "business": return .business
        case "personal": return .personal
        default: return .unknown
        }
    }
}

public class BankAccountInfo: PaymentMethodRequestBase {
    @objc public var bankRoutingNumber: String?
    @objc public var bankAccountNumber: SpreedlySecureOpaqueString?
    @objc public var bankAccountType: BankAccountType = .unknown
    @objc public var bankAccountHolderType: BankAccountHolderType = .unknown

    @objc public init() {
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

    @objc public init(
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

    public init(fromInfo info: PaymentMethodRequestBase?) {
        super.init(from: info)
    }

    /// Copies values from another BankAccountInfo instance
    /// including fullName, firstName, lastName, address,
    /// shippingAddress, company, email, metadata,
    /// bankAccountType, and bankAccountHolderType.
    ///
    /// Account data is not copied.
    /// - Parameter info: The source of the values.
    public convenience init(fromBankAccount info: BankAccountInfo?) {
        self.init(fromInfo: info)

        bankAccountType = info?.bankAccountType ?? BankAccountType.unknown
        bankAccountHolderType = info?.bankAccountHolderType ?? BankAccountHolderType.unknown
    }

    override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        result.maybeSet("bank_routing_number", bankRoutingNumber)
        try result.setOpaqueString("bank_account_number", bankAccountNumber)
        result.maybeSet("bank_account_type", bankAccountType.stringValue)
        result.maybeSet("bank_account_holder_type", bankAccountHolderType.stringValue)

        return result
    }

    override func toRequestJson() throws -> [String: Any] {
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
    @objc public var testCardNumber: String?

    @objc public convenience init(firstName: String, lastName: String, paymentTokenData: Data) {
        self.init(fullName: nil, firstName: firstName, lastName: lastName, paymentTokenData: paymentTokenData)
    }

    @objc public convenience init(firstName: String, lastName: String, payment: PKPayment) {
        self.init(firstName: firstName, lastName: lastName, paymentTokenData: payment.token.paymentData)
    }

    @objc public convenience init(fullName: String, paymentTokenData: Data) {
        self.init(fullName: fullName, firstName: nil, lastName: nil, paymentTokenData: paymentTokenData)
    }

    @objc public convenience init(fullName: String, payment: PKPayment) {
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

    override func toRequestJson() throws -> [String: Any] {
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

        paymentMethod.merge(address.toJson(type: .billing), uniquingKeysWith: { $1 })
        paymentMethod.merge(shippingAddress.toJson(type: .shipping), uniquingKeysWith: { $1 })

        return [
            "payment_method": paymentMethod
        ]
    }
}
