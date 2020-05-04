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
        let config = URLSessionConfiguration.default
        let userPasswordString = "\(env):\(secret)"
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

    func createCreditCardPaymentMethod(
            creditCard: CreditCard,
            email: String? = nil,
            metadata: [String: String]? = nil,
            retained: Bool? = nil
    ) -> Single<Transaction<CreditCard>> {
        let url = baseUrl.appendingPathComponent("/payment_methods.json", isDirectory: false)

        let request = CreatePaymentMethodRequest(
                email: email ?? "",
                metadata: metadata ?? [:],
                creditCard: creditCard,
                retained: retained
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

extension SpreedlyClientImpl {
    static func decode<T>(data: Data) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }

    static func encode<TEntity>(entity: TEntity) throws -> Data where TEntity: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        return try encoder.encode(entity)
    }
}
