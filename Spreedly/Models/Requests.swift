import Foundation

/// Metadata key-value pairs (limit 25). Keys are limited to 50 characters.
/// Values are limited to 500 characters and cannot contain compounding data types.
public typealias Metadata = [String: Any]

/// A set of information used when creating payment methods with Spreedly.
public class PaymentMethodInfo: NSObject {
    @objc public var email: String?
    @objc public var metadata: Metadata?

    @objc public var fullName: String?
    @objc public var firstName: String?
    @objc public var lastName: String?
    @objc public var company: String?

    /// When provided, will pass `address1`, `address2`, `city`, `state`, `zip`, `country`,
    /// and `phone_number` properties to Spreedly when creating a payment method from this object.
    @objc public var address: Address

    /// When provided, will pass `shipping_address1`, `shipping_address2`, `shipping_city`, `shipping_state`,
    /// `shipping_zip`, `shipping_country`, and `shipping_phone_number` properties to Spreedly
    /// when creating a payment method from this object.
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

    public override convenience init() {
        self.init(fullName: nil, firstName: nil, lastName: nil)
    }

    /// Copies values from the given PaymentMethodInfo into a new instance.
    public init(from info: PaymentMethodInfo?) {
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

/// A set of information used when creating a credit card payment method with Spreedly.
public class CreditCardInfo: PaymentMethodInfo {
    @objc public var number: SpreedlySecureOpaqueString?
    @objc public var verificationValue: SpreedlySecureOpaqueString?

    /// Expiration year.
    public var year: Int?

    /// Expiration month.
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

    /// Copies values from the given PaymentMethodInfo onto a new CreditCardInfo.
    public init(fromInfo info: PaymentMethodInfo?) {
        super.init(from: info)
    }

    /// Copies values from another CreditCardInfo instance
    /// including `fullName`, `firstName`, `lastName`, `address`,
    /// `shippingAddress`, `company`, `email`, and `metadata`.
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
    /// Expiration year.
    @objc(year) public var _objCYear: Int { // swiftlint:disable:this identifier_name
        get {
            year ?? 0
        }
        set {
            self.year = newValue
        }
    }

    /// Expiration month.
    @objc(month) public var _objCMonth: Int { // swiftlint:disable:this identifier_name
        get {
            month ?? 0
        }
        set {
            self.month = newValue
        }
    }
}
