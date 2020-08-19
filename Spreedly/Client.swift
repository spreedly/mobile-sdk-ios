//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift

/// A set of methods used to create payment methods and recache verification values.
/// Returns single-element sequences of `Transaction` to be handled asynchronously.
public protocol SpreedlyClient {
    /// Attempts to create a credit card payment method.
    func createPaymentMethodFrom(creditCard: CreditCardInfo) -> Single<Transaction>
    /// Attempts to create a bank account payment method.
    func createPaymentMethodFrom(bankAccount: BankAccountInfo) -> Single<Transaction>
    /// Attempts to recache the verification value for a payment method identified by the token.
    func recache(token: String, verificationValue: SpreedlySecureOpaqueString) -> Single<Transaction>
    /// Attempts to create an Apple Pay payment method.
    func createPaymentMethodFrom(applePay: ApplePayInfo) -> Single<Transaction>
}

public enum SpreedlySecurityError: Error {
    case invalidOpaqueString
}

/// A set of methods used to create payment methods and recache verification values.
/// Returns single-element sequences of `SPRTransaction` to be handled asynchronously.
@objc(SPRClient)
public protocol _ObjCClient {
    /// Attempts to create a payment method.
    @objc(createPaymentMethodFrom:)
    func _objCCreatePaymentMethod(from: PaymentMethodInfo) -> _ObjCSingleTransaction // swiftlint:disable:this identifier_name line_length

    /// Attempts to recache the verification value for a payment method identified by the token.
    @objc(recacheWithToken:verificationValue:)
    func _objCRecache(token: String, verificationValue: SpreedlySecureOpaqueString) -> _ObjCSingleTransaction // swiftlint:disable:this identifier_name line_length
}
