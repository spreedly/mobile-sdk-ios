//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift

/// Spreedly core client
public protocol SpreedlyClient {

    /// creates a secure string
    ///
    /// This class is used by various calls to expose a mutable string that
    /// can't be easily read or stored in local data stores.
    ///
    /// - Returns: an empty SpreedlySecureOpaqueString.
    func createSecureString() -> SpreedlySecureOpaqueString

    /// creates a secure string
    ///
    /// This class is used by various calls to expose a mutable string that
    /// can't be easily read or stored in local data stores.
    ///
    /// - Returns: a SpreedlySecureOpaqueString with the specified contents.
    func createSecureString(from source: String) -> SpreedlySecureOpaqueString

    func createCreditCardPaymentMethod(
            creditCard: CreditCardInfo
    ) -> Single<Transaction<CreditCardResult>>

    func createCreditCardPaymentMethod(
            creditCard: CreditCardInfo,
            email: String?,
            metadata: [String: String]?
    ) -> Single<Transaction<CreditCardResult>>

    func createBankAccountPaymentMethod(
            bankAccount: BankAccountInfo
    ) -> Single<Transaction<BankAccountResult>>

    func createBankAccountPaymentMethod(
            bankAccount: BankAccountInfo,
            email: String?,
            metadata: [String: String?]?
    ) -> Single<Transaction<BankAccountResult>>

    func recache(
            token: String,
            verificationValue: SpreedlySecureOpaqueString
    ) -> Single<Transaction<CreditCardResult>>

    func createApplePayPaymentMethod(
            applePay: ApplePayInfo
    ) -> Single<Transaction<ApplePayResult>>

    func createApplePayPaymentMethod(
            applePay: ApplePayInfo,
            email: String?,
            metadata: [String: String]?
    ) -> Single<Transaction<ApplePayResult>>
}

public enum SpreedlySecurityError: Error {
    case invalidOpaqueString
}

public func createSpreedlyClient(envKey: String, envSecret: String, test: Bool = false) -> SpreedlyClient {
    SpreedlyClientImpl(envKey: envKey, envSecret: envSecret, test: test)
}

@objc public protocol SpreedlySecureOpaqueString {
    func clear()

    func append(_ string: String)

    func removeLastCharacter()
}
