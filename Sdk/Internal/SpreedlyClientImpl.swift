//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift
import RxCocoa

class SpreedlyClientImpl: NSObject, SpreedlyClient {
    let env: String
    let secret: String
    let baseUrl = URL(string: "https://core.spreedly.com/v1")!

    init(env: String, secret: String) {
        self.env = env
        self.secret = secret
        super.init()
    }

    func session() -> URLSession {
        Util(envKey: self.env, envSecret: self.secret).urlSession()
    }

    func createSecureString() -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl()
    }

    func createSecureString(from source: String) -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl(from: source)
    }

    func createCreditCardPaymentMethod(
            creditCard: CreditCard,
            email: String? = nil,
            metadata: [String: String]? = nil
    ) -> Single<Transaction<CreditCard>> {
        let url = baseUrl.appendingPathComponent("/payment_methods.json", isDirectory: false)

        let request = CreatePaymentMethodRequest(email: email ?? "", metadata: metadata ?? [:], creditCard: creditCard)

        let jsonRequest: Data
        do {
            jsonRequest = try request.wrapToData()
        } catch {
            return Single.error(error)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonRequest

        return session().rx
                .data(request: urlRequest)
                .asSingle()
                .do(onSuccess: { data in
                    let json = String(data: data, encoding: .utf8) ?? "unable to decode data"
                    print("Response was\n", json)
                }).map { data -> Transaction<CreditCard> in
                    try Transaction<CreditCard>.unwrapFrom(data: data)
                }
    }

    func createBankAccountPaymentMethod(
            bankAccount: BankAccount,
            email: String? = nil,
            data: [String: String?]? = nil,
            metadata: [String: String?]? = nil
    ) -> Single<Transaction<BankAccount>> {
        let url = baseUrl.appendingPathComponent("/payment_methods.json")

        let request = CreateBankAccountPaymentMethodRequest(
                bankAccount: bankAccount,
                email: email,
                data: data,
                metadata: metadata
        )

        let jsonRequest: Data
        do {
            jsonRequest = try request.wrapToData()
        } catch {
            return Single.error(error)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonRequest

        return session().rx
                .data(request: urlRequest)
                .asSingle()
                .do(onSuccess: { data in
                    let json = String(data: data, encoding: .utf8) ?? "unable to decode data"
                    print("Response was\n", json)
                }).map { data -> Transaction<BankAccount> in
                    try Transaction<BankAccount>.unwrapFrom(data: data)
                }
    }

    func recache(token: String, verificationValue: String) -> Single<Transaction<CreditCard>> {
        let url = baseUrl.appendingPathComponent("/payment_methods/\(token)/recache.json")

        var creditCard = CreditCard()
        creditCard.verificationValue = verificationValue

        let request = CreateRecacheRequest(creditCard: creditCard)

        let jsonRequest: Data
        do {
            jsonRequest = try request.wrapToData()
        } catch {
            return Single.error(error)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonRequest

        return session().rx
                .data(request: urlRequest)
                .asSingle()
                .do(onSuccess: { data in
                    let json = String(data: data, encoding: .utf8) ?? "unable to decode data"
                    print("Response was\n", json)
                }).map { data -> Transaction<CreditCard> in
                    try Transaction<CreditCard>.unwrapFrom(data: data)
                }
    }
}
