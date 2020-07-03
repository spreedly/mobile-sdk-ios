//
// Created by Eli Thompson on 5/12/20.
//

import RxSwift
import Spreedly

@objc(SPRHelpers)
public class Helpers: NSObject {
    @objc public static let testCardNumber = "4111111111111111"
    @objc public static let verificationValue = "919"
    @objc public static let testBankRoutingNumber = "021000021"
    @objc public static let testBankAccountNumber = "9876543210"

    @objc public static var key: String {
        ProcessInfo.processInfo.environment["ENV_KEY"] ?? secretEnvKey
    }

    @objc public static var secret: String {
        ProcessInfo.processInfo.environment["ENV_SECRET"] ?? secretEnvSecret
    }

    @objc public static var secureTestCardNumber: SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringBuilder.build(from: testCardNumber)
    }

    @objc public static var secureVerificationValue: SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringBuilder.build(from: verificationValue)
    }

    @objc public static var secureBankAccountNumber: SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringBuilder.build(from: testBankAccountNumber)
    }

    static func createClient() -> SpreedlyClient {
        ClientFactory.create(envKey: key, envSecret: secret, test: true)
    }

    static func createCreditCard(retained: Bool? = nil) throws -> Single<Transaction<CreditCardResult>> {
        let client = createClient()
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: secureTestCardNumber,
                verificationValue: secureVerificationValue,
                year: 2029,
                month: 1
        )
        creditCard.retained = retained
        creditCard.email = "dolly@dog.com"

        return client.createPaymentMethodFrom(creditCard: creditCard)
    }
}

extension Helpers {
    @objc(createClient)
    public static func _objCCreateClient() -> _ObjCClient { // swiftlint:disable:this identifier_name
        ClientFactory._objCCreate(envKey: key, envSecret: secret, test: true)
    }
}

// swiftlint:disable line_length
extension Helpers {
    @objc public static let paymentTokenData = #"""
                           {
                               "version": "EC_v1",
                               "data": "edGGW2rTsZHagCxDkZBJNqYbApkCk1kHzLFBbMNN7fGD+wmE8nne6IkZx0aF0ybDqoPFAxj/0bt75VgZEyPIi3oed3SAx8jwEBsACkZFGqjco17CdSn/hAR2lCkZNxi7KTnch6CgMEu5cm0aCQ/x5dfXo43yOJLiqSg0aQ7g7xHUp/AGkES9p7QuaCMCVVn85Mmqo0Dv5LxhuT4VAYVytOdvbeA6lP1AwgXAkrbY1SI3Kbv0CbAbiyxBivjYpbemqpeYKJwa5KN2qJd1HJJe0g6rRotr3VlRkBjOT+q1WpCvbJA44N3Y9tftszF1VNOXtK95XCJ26miqmtjL5gOzmv2aBhzj5/gb/lVR2sppmuAaFbQ8ciyabhUjsrhjgbAop+Oz0gkv7Mb+TtaUKg==",
                               "signature": "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",
                               "header": {
                                   "ephemeralPublicKey": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAERVQiZozHKWeFC3Bo2pAiNmC6AA+MBBy/odkuDE6NI244PHZvc7KNK7T7xe3dEpeQlkwZIziVru+MCgw42NMqSw==",
                                   "publicKeyHash": "WArZFTOhuVvqyLurl07xWCytBgd6gWlMQoecT4Q+tzI=",
                                   "transactionId": "4b36e0a9b848afee515d6c046511cf1af58c6deeba6baa432f0f634280d53a80"
                               }
                           }
                           """#.data(using: .utf8)!
}
// swiftlint:enable line_length
