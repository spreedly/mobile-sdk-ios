//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift

public protocol SpreedlyClient {
    func createPaymentMethodFrom(creditCard: CreditCardInfo) -> Single<Transaction>

    func createPaymentMethodFrom(bankAccount: BankAccountInfo) -> Single<Transaction>

    func recache(token: String, verificationValue: SpreedlySecureOpaqueString) -> Single<Transaction>

    func createPaymentMethodFrom(applePay: ApplePayInfo) -> Single<Transaction>
}

public enum SpreedlySecurityError: Error {
    case invalidOpaqueString
}

@objc(SPRClient)
public protocol _ObjCClient {
    @objc(createPaymentMethodFrom:)
    func _objCCreatePaymentMethod(from: PaymentMethodInfo) -> _ObjCSingleTransaction // swiftlint:disable:this identifier_name line_length

    @objc(recacheWithToken:verificationValue:)
    func _objCRecache(token: String, verificationValue: SpreedlySecureOpaqueString) -> _ObjCSingleTransaction // swiftlint:disable:this identifier_name line_length
}
