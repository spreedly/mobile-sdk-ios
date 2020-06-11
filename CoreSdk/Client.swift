//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift

public protocol SpreedlyClient {
    func createCreditCardPaymentMethod(
            creditCard: CreditCardInfo
    ) -> Single<Transaction<CreditCardResult>>

    func createCreditCardPaymentMethod(
            creditCard: CreditCardInfo,
            email: String?,
            metadata: Metadata?
    ) -> Single<Transaction<CreditCardResult>>

    func createBankAccountPaymentMethod(
            bankAccount: BankAccountInfo
    ) -> Single<Transaction<BankAccountResult>>

    func createBankAccountPaymentMethod(
            bankAccount: BankAccountInfo,
            email: String?,
            metadata: Metadata?
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
            metadata: Metadata?
    ) -> Single<Transaction<ApplePayResult>>
}

public enum SpreedlySecurityError: Error {
    case invalidOpaqueString
}

@objc(SPRClient)
public protocol _ObjCClient {
    @objc(createPaymentMethodFrom:)
    func _objCCreatePaymentMethod(
            from: PaymentMethodRequestBase
    ) -> _ObjCSingleTransaction
}
