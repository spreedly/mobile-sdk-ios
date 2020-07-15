//
// Created by Eli Thompson on 7/13/20.
//

import Foundation
import PassKit

/// A set of information used when creating an Apple Pay payment method with Spreedly.
public class ApplePayInfo: PaymentMethodInfo {
    let paymentToken: Data

    /// Set this to a [Spreedly test card number](https://docs.spreedly.com/reference/test-data/#credit-cards) when
    /// testing Apple Pay.
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

    /// Copies values from the given PaymentMethodInfo onto a new instance.
    public init(fromInfo info: PaymentMethodInfo?, payment: PKPayment) {
        paymentToken = payment.token.paymentData
        super.init(from: info)
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
