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
    let testCardNumber: String?
    static let baseUrl = URL(string: "https://core.spreedly.com/v1")!
    let authenticatedPaymentMethodUrl = SpreedlyClientImpl.baseUrl.appendingPathComponent(
            "/payment_methods.json", isDirectory: false
    )
    let unauthenticatedPaymentMethodUrl = SpreedlyClientImpl.baseUrl.appendingPathComponent(
            "/payment_methods/restricted.json", isDirectory: false
    )

    init(envKey: String, envSecret: String, test: Bool, testCardNumber: String? = nil) {
        self.envKey = envKey
        self.envSecret = envSecret
        self.test = test
        self.testCardNumber = testCardNumber
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
        let userPasswordString = "\(envKey):\(envSecret)"
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
        if test {
            info.testCardNumber = testCardNumber
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
                "environment_key": self.envKey,
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
                request["environment_key"] = self.envKey
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
        let url: URL
        let authenticated: Bool
        if info.retained ?? false {
            authenticated = true
            url = authenticatedPaymentMethodUrl
        } else {
            authenticated = false
            url = unauthenticatedPaymentMethodUrl
        }

        let single = Single<Transaction>.deferred {
            var request = try info.toRequestJson()
            if !authenticated {
                request["environment_key"] = self.envKey
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try request.encodeJson()

            return self.process(request: urlRequest, authenticated: authenticated).map { data -> Transaction in
                try Transaction.unwrap(from: data)
            }
        }

        return _ObjCSingleTransaction(observable: single)
    }
}
