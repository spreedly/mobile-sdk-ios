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
    @objc public var allowBlankName: Bool = false

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

    @objc public override init() {
        self.address = Address()
        self.shippingAddress = Address()
    }

    /// Copies values from the given PaymentMethodInfo into a new instance.
    public init(copyFrom info: PaymentMethodInfo?) {
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

        if (allowBlankName) {
            result["allow_blank_name"] = true
        }

        result.merge(address.toJson(type: .billing), uniquingKeysWith: { $1 })
        result.merge(shippingAddress.toJson(type: .shipping), uniquingKeysWith: { $1 })

        return result
    }

    internal func toRequestJson() throws -> [String: Any] {
        fatalError("must be overridden")
    }
}
