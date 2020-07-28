//
// Created by Eli Thompson on 7/13/20.
//

import Foundation

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
