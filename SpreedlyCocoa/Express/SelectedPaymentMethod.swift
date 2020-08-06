//
// Created by Eli Thompson on 7/29/20.
//

import Foundation
import Spreedly

/// Contains data about the payment method selected by the user from the `PaymentSelectionViewController`.
@objc(SPRSelectedPaymentMethod)
public class SelectedPaymentMethod: NSObject {
    /// Spreedly's payment method token
    @objc public let token: String

    /// The payment method type
    public let type: PaymentMethodType

    /// If the payment method was created by the user before selection, this will contain the payment method object.
    @objc public var paymentMethod: PaymentMethodResultBase?

    public init(token: String, type: PaymentMethodType) {
        self.token = token
        self.type = type
    }
}

extension SelectedPaymentMethod {
    /// The payment method type
    @objc(type)
    public var _objCType: _ObjCPaymentMethodType { // swiftlint:disable:this identifier_name
        _ObjCPaymentMethodType.from(type)
    }
}
