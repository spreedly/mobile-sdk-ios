//
// Created by Eli Thompson on 5/12/20.
//

import RxSwift
import CoreSdk

class Helpers {
    static let testCardNumber = "4111111111111111"
    static let verificationValue = "919"

    static func createClient() -> SpreedlyClient {
        let key = ProcessInfo.processInfo.environment["ENV_KEY"] ?? secretEnvKey
        let secret = ProcessInfo.processInfo.environment["ENV_SECRET"] ?? secretEnvSecret
        return createSpreedlyClient(envKey: key, envSecret: secret, test: true)
    }

    static func createCreditCard(retained: Bool? = nil) throws -> Single<Transaction<CreditCardResult>> {
        let client = createClient()
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: SpreedlySecureOpaqueStringBuilder.build(from: testCardNumber),
                verificationValue: SpreedlySecureOpaqueStringBuilder.build(from: verificationValue),
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
