//
// Created by Eli Thompson on 5/12/20.
//

import RxSwift
import CoreSdk

@objc(SPRHelpers)
public class Helpers: NSObject {
    @objc public static let testCardNumber = "4111111111111111"
    @objc public static let verificationValue = "919"

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

    static func createClient() -> SpreedlyClient {
        createSpreedlyClient(envKey: key, envSecret: secret, test: true)
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

        return client.createCreditCardPaymentMethod(
                creditCard: creditCard,
                email: "dolly@dog.com",
                metadata: nil
        )
    }
}

extension Helpers {
    @objc(createClient)
    public static func _objCCreateClient() -> _ObjCClient {
        _ObjCClientFactory.createClient(envKey: key, envSecret: secret, test: true)
    }
}
