//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift

public protocol SpreedlyClient {
    func createCreditCardPaymentMethod(creditCard: CreditCardInfo) -> Single<Transaction<CreditCardResult>>

    func createBankAccountPaymentMethod(bankAccount: BankAccountInfo) -> Single<Transaction<BankAccountResult>>

    func recache(token: String, verificationValue: SpreedlySecureOpaqueString) -> Single<Transaction<CreditCardResult>>

    func createApplePayPaymentMethod(applePay: ApplePayInfo) -> Single<Transaction<ApplePayResult>>
}

public enum SpreedlySecurityError: Error {
    case invalidOpaqueString
}

@objc(SPRClient)
public protocol _ObjCClient {
    @objc(createPaymentMethodFrom:)
    func _objCCreatePaymentMethod(from: PaymentMethodRequestBase) -> _ObjCSingleTransaction
}
