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
            creditCard: CreditCard,
            email: String?,
            metadata: [String: String]?,
            retained: Bool?
    ) -> Single<Transaction<CreditCard>>

    func createBankAccountPaymentMethod(
            bankAccount: BankAccount,
            email: String?,
            metadata: [String: String?]?
    ) -> Single<Transaction<BankAccount>>

    func recache(token: String, verificationValue: String) -> Single<Transaction<CreditCard>>
}

public func createSpreedlyClient(envKey: String, envSecret: String, test: Bool = false) -> SpreedlyClient {
    SpreedlyClientImpl(envKey: envKey, envSecret: envSecret, test: test)
}

@objc public protocol SpreedlySecureOpaqueString {
    func clear()

    func append(_ string: String)

    func removeLastCharacter()
}
