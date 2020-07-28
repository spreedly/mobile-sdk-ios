//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import RxSwift
import RxCocoa

class SpreedlyClientImpl: NSObject, SpreedlyClient {
    let config: ClientConfiguration
    static let baseUrl = URL(string: "https://core.spreedly.com/v1")!
    let authenticatedPaymentMethodUrl = SpreedlyClientImpl.baseUrl.appendingPathComponent(
            "/payment_methods.json", isDirectory: false
    )
    let unauthenticatedPaymentMethodUrl = SpreedlyClientImpl.baseUrl.appendingPathComponent(
            "/payment_methods/restricted.json", isDirectory: false
    )

    init(with config: ClientConfiguration) {
        self.config = config
        super.init()
    }

    func session(authenticated: Bool = false) -> URLSession {
        var headers: [String: String] = ["Content-Type": "application/json"]
        if authenticated {
            headers["Authorization"] = "Basic \(encodedCredentials)"
        }

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = headers
        return URLSession(configuration: config)
    }

    private var encodedCredentials: String {
        let userPasswordString = "\(config.envKey):\(config.envSecret ?? "")"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        return userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    func createPaymentMethodFrom(creditCard info: CreditCardInfo) -> Single<Transaction> {
        createPaymentMethod(from: info)
    }

    func createPaymentMethodFrom(bankAccount info: BankAccountInfo) -> Single<Transaction> {
        createPaymentMethod(from: info)
    }

    func createPaymentMethodFrom(applePay info: ApplePayInfo) -> Single<Transaction> {
        if config.test {
            info.testCardNumber = config.testCardNumber
        }
        return createPaymentMethod(from: info)
    }

    func recache(
            token: String,
            verificationValue: SpreedlySecureOpaqueString
    ) -> Single<Transaction> {
        let url = SpreedlyClientImpl.baseUrl.appendingPathComponent(
                "/payment_methods/\(token)/recache.json", isDirectory: false
        )

        return Single.deferred {
            var creditCardJson = [String: Any]()
            try creditCardJson.setOpaqueString("verification_value", verificationValue)
            let request: [String: Any] = [
                "environment_key": self.config.envKey,
                "payment_method": [
                    "credit_card": creditCardJson
                ]
            ]

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(request: urlRequest).map { data -> Transaction in
                try Transaction.unwrap(from: data)
            }
        }
    }

    func createPaymentMethod(
            from info: PaymentMethodInfo
    ) -> Single<Transaction> {
        Single.deferred {
            let authenticated = info.retained ?? false

            var request = try info.toRequestJson()
            let url: URL

            if authenticated {
                url = self.authenticatedPaymentMethodUrl
            } else {
                url = self.unauthenticatedPaymentMethodUrl
                request["environment_key"] = self.config.envKey
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(
                    request: urlRequest,
                    authenticated: authenticated
            ).map { data -> Transaction in
                try Transaction.unwrap(from: data)
            }
        }
    }

    func process(request: URLRequest, authenticated: Bool = false) -> Single<Data> {
        session(authenticated: authenticated).rx
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

extension SpreedlyClientImpl: _ObjCClient {
    @objc(createPaymentMethodFrom:)
    func _objCCreatePaymentMethod(from info: PaymentMethodInfo) -> _ObjCSingleTransaction { // swiftlint:disable:this identifier_name line_length
        let observable = createPaymentMethod(from: info)
        return _ObjCSingleTransaction(observable: observable)
    }

    func _objCRecache(token: String, verificationValue: SpreedlySecureOpaqueString) -> _ObjCSingleTransaction { // swiftlint:disable:this identifier_name line_length
        let observable = recache(token: token, verificationValue: verificationValue)
        return _ObjCSingleTransaction(observable: observable)
    }
}
