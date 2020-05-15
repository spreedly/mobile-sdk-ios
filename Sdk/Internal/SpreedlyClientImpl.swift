//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift
import RxCocoa

class SpreedlyClientImpl: NSObject, SpreedlyClient {
    let envKey: String
    let envSecret: String
    let test: Bool
    let baseUrl = URL(string: "https://core.spreedly.com/v1")!

    init(envKey: String, envSecret: String, test: Bool) {
        self.envKey = envKey
        self.envSecret = envSecret
        self.test = test
        super.init()
    }

    func session() -> URLSession {
        let config = URLSessionConfiguration.default
        let userPasswordString = "\(envKey):\(envSecret)"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let encodedCredentials = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        config.httpAdditionalHeaders = [
            "Authorization": "Basic \(encodedCredentials)",
            "Content-Type": "application/json"
        ]

        return URLSession(configuration: config)
    }

    func createSecureString() -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl()
    }

    func createSecureString(from source: String) -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl(from: source)
    }

    func createCreditCardPaymentMethod(creditCard: CreditCardInfo) -> Single<Transaction<CreditCardResult>> {
        createCreditCardPaymentMethod(creditCard: creditCard, email: nil, metadata: nil)
    }

    func createCreditCardPaymentMethod(
            creditCard info: CreditCardInfo,
            email: String? = nil,
            metadata: [String: String]? = nil
    ) -> Single<Transaction<CreditCardResult>> {
        let url = baseUrl.appendingPathComponent("/payment_methods.json", isDirectory: false)

        return Single.deferred {
            let request = info.toRequestJson(email: email, metadata: metadata)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(request: urlRequest).map { data -> Transaction<CreditCardResult> in
                try Transaction<CreditCardResult>.unwrapFrom(data: data)
            }
        }
    }

    func createBankAccountPaymentMethod(bankAccount: BankAccountInfo) -> Single<Transaction<BankAccountResult>> {
        createBankAccountPaymentMethod(bankAccount: bankAccount, email: nil, metadata: nil)
    }

    func createBankAccountPaymentMethod(
            bankAccount info: BankAccountInfo,
            email: String? = nil,
            metadata: [String: String]? = nil
    ) -> Single<Transaction<BankAccountResult>> {
        let url = baseUrl.appendingPathComponent("/payment_methods.json", isDirectory: false)

        return Single.deferred {
            let request = try info.toRequestJson(email: email, metadata: metadata)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(request: urlRequest).map { data -> Transaction<BankAccountResult> in
                try Transaction<BankAccountResult>.unwrapFrom(data: data)
            }
        }
    }

    func recache(token: String, verificationValue: SpreedlySecureOpaqueString) -> Single<Transaction<CreditCardResult>> {
        let url = baseUrl.appendingPathComponent("/payment_methods/\(token)/recache.json", isDirectory: false)

        return Single.deferred {
            var creditCardJson: [String: Any] = [:]
            try creditCardJson.setOpaqueString("verification_value", verificationValue)
            let request: [String: Any] = [
                "payment_method": [
                    "credit_card": creditCardJson
                ]
            ]

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(request: urlRequest).map { data -> Transaction<CreditCardResult> in
                try Transaction<CreditCardResult>.unwrapFrom(data: data)
            }
        }
    }

    func createApplePayPaymentMethod(applePay info: ApplePayInfo) -> Single<Transaction<ApplePayResult>> {
        createApplePayPaymentMethod(applePay: info, email: nil, metadata: nil)
    }

    func createApplePayPaymentMethod(
            applePay info: ApplePayInfo,
            email: String?,
            metadata: [String: String]?
    ) -> Single<Transaction<ApplePayResult>> {
        let url = baseUrl.appendingPathComponent("/payment_methods.json", isDirectory: false)

        return Single.deferred {
            let request = try info.toRequestJson(email: email, metadata: metadata)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(request: urlRequest).map { data -> Transaction<ApplePayResult> in
                try Transaction<ApplePayResult>.unwrapFrom(data: data)
            }
        }
    }

    func process(request: URLRequest) -> Single<Data> {
        session().rx
                .data(request: request)
                .catchError { error in
                    switch error {
                    case RxCocoaURLError.httpRequestFailed(response: _, data: let data):
                        return Observable.from(optional: data)
                    default:
                        return Observable.error(error)
                    }
                }
                .asSingle()
                .do(onSuccess: { data in
                    let json = String(data: data, encoding: .utf8) ?? "unable to decode data"
                    print("Response was\n", json)
                })
    }
}
