//
// Created by Eli Thompson on 5/12/20.
//

import RxSwift
@testable import Sdk

class Helpers {
    static let testCardNumber = "4111111111111111"
    static let verificationValue = "919"

    static func createClient() -> SpreedlyClientImpl {
        let key = ProcessInfo.processInfo.environment["ENV_KEY"] ?? secretEnvKey
        let secret = ProcessInfo.processInfo.environment["ENV_SECRET"] ?? secretEnvSecret
        return SpreedlyClientImpl(envKey: key, envSecret: secret, test: true)
    }

    static func createCreditCard(retained: Bool? = nil) throws -> Single<Transaction<CreditCardResult>> {
        let client = createClient()
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: testCardNumber),
                verificationValue: client.createSecureString(from: verificationValue),
                year: 2029,
                month: 1
        )
        creditCard.retained = retained

        return client.createCreditCardPaymentMethod(
                creditCard: creditCard,
                email: "dolly@dog.com"
        )
    }
}
