//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

class SpreedlyClientImpl: NSObject, SpreedlyClient {
    let config: ClientConfiguration
    static let baseUrl = URL(string: "https://core.spreedly.com/v1")!
    let authenticatedPaymentMethodUrl = SpreedlyClientImpl.baseUrl.appendingPathComponent(
            "/payment_methods.json", isDirectory: false
    )
    let unauthenticatedPaymentMethodUrl = SpreedlyClientImpl.baseUrl.appendingPathComponent(
            "/payment_methods/restricted.json", isDirectory: false
    )

    func authenticatedPurchaseUrl(_ gateway: String) -> URL {
        SpreedlyClientImpl.baseUrl.appendingPathComponent(
                "/gateways/" + gateway + "/purchase.json", isDirectory: false
        )
    }

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
        let session = URLSession(configuration: config)
        return session
    }

    private var encodedCredentials: String {
        let userPasswordString = "\(config.envKey):\(config.envSecret ?? "")"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        return userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    func createPaymentMethodFrom(creditCard info: CreditCardInfo) -> SingleTransaction {
        createPaymentMethod(from: info)
    }

    func createPaymentMethodFrom(bankAccount info: BankAccountInfo) -> SingleTransaction {
        createPaymentMethod(from: info)
    }

    func createPaymentMethodFrom(applePay info: ApplePayInfo) -> SingleTransaction {
        if config.test {
            info.testCardNumber = config.testCardNumber
        }
        return createPaymentMethod(from: info)
    }

    func recache(
            token: String,
            verificationValue: SpreedlySecureOpaqueString
    ) -> SingleTransaction {
        let url = SpreedlyClientImpl.baseUrl.appendingPathComponent(
                "/payment_methods/\(token)/recache.json", isDirectory: false
        )

        let source = SingleTransactionSource()
        DispatchQueue.global().async {
            var creditCardJson = [String: Any]()
            try? creditCardJson.setOpaqueString("verification_value", verificationValue)
            let request: [String: Any] = [
                "environment_key": self.config.envKey,
                "payment_method": [
                    "credit_card": creditCardJson
                ]
            ]

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? request.encodeJson()
            guard urlRequest.httpBody != nil else {
                source.handleError(error: ClientError.invalidRequestData)
                return
            }
            self.process(source: source, request: urlRequest)
        }
        return SingleTransaction(source: source)
    }

    func createPaymentMethod(
            from info: PaymentMethodInfo
    ) -> SingleTransaction {
        let source = SingleTransactionSource()
        DispatchQueue.global().async {
            let authenticated = info.retained ?? false

            guard var request = try? info.toRequestJson() else {
                source.handleError(error: ClientError.invalidRequestData)
                return
            }
            let url: URL

            if authenticated {
                url = self.authenticatedPaymentMethodUrl
            } else {
                url = self.unauthenticatedPaymentMethodUrl
                request["environment_key"] = self.config.envKey
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? request.encodeJson()
            guard urlRequest.httpBody != nil else {
                source.handleError(error: ClientError.invalidRequestData)
                return
            }

            self.process(
                    source: source,
                    request: urlRequest,
                    authenticated: authenticated
            )
        }
        return SingleTransaction(source: source)
    }

    func process(source: SingleTransactionSource, request: URLRequest, authenticated: Bool = false) {
        let session = self.session(authenticated: authenticated)
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                let json = String(data: data, encoding: .utf8) ?? "unable to decode data"
                print("Response was\n", json)
                let transaction = try? Transaction.unwrap(from: data)
                if let transaction = transaction {
                    source.handleSuccess(transaction: transaction)
                } else {
                    source.handleError(error: ClientError.parseError)
                }
                return;
            }
            if let error = error {
                source.handleError(error: error)
                return;
            }
            source.handleError(error: ClientError.invalidRequestData)
        }.resume()
    }
}

extension SpreedlyClientImpl: _ObjCClient {
    @objc(createPaymentMethodFrom:)
    func _objCCreatePaymentMethod(from info: PaymentMethodInfo) -> SingleTransaction { // swiftlint:disable:this identifier_name line_length
        createPaymentMethod(from: info)
    }

    @objc(recacheWithToken:verificationValue:)
    func _objCRecache(token: String, verificationValue: SpreedlySecureOpaqueString) -> SingleTransaction { // swiftlint:disable:this identifier_name line_length
        recache(token: token, verificationValue: verificationValue)
    }
}
