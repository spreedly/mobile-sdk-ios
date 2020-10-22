//
// Created by Eli Thompson on 7/8/20.
//

import Foundation

// swiftlint:disable line_length

/// Contains configuration values used by the SpreedlyClient implementation.
/// - envKey: The [environment key](https://docs.spreedly.com/basics/credentials/#environment-key) is required for all communication with Spreedly.
/// - envSecret: The environment secret is only used by integration tests and should not be set in production.
/// - test: Set to true when the client will be used for testing to enable test-specific behaviors.
/// - testCardNumber: When using Apple Pay, there is no way to request a test payment method from the Passkit framework. Instead, pass set this property to one of the above [test credit card numbers](https://docs.spreedly.com/reference/test-data/#credit-cards) and Spreedly will recognize it as a test payment method. This *only* applies when creating Apple Pay payment methods.
@objc(SPRClientConfiguration)
public class ClientConfiguration: NSObject {
    /// Spreedly environment key
    @objc public let envKey: String
    /// Spreedly environment secret. Only used in integration tests.
    @objc public let envSecret: String?
    /// Test-mode flag.
    @objc public let test: Bool
    /// Card number used when in test-mode when creating Apple Pay payment methods.
    @objc public let testCardNumber: String?

    @objc public init(envKey: String, envSecret: String? = nil, test: Bool = false, testCardNumber: String? = nil) {
        self.envKey = envKey
        self.envSecret = envSecret
        self.test = test
        self.testCardNumber = testCardNumber
    }

    /// Attempts to read values from `Spreedly-env.plist` in the main bundle and returns a ClientConfiguration
    /// initialized with the values therein.
    /// - Throws: `ClientError.noSpreedlyCredentials` Spreedly-env.plist file cannot be found or it does not contain an `ENV_KEY` entry with a value.
    @objc public static func getConfiguration() throws -> ClientConfiguration {
        guard let path = Bundle.main.path(forResource: "Spreedly-env", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let envKey = config["ENV_KEY"] as? String,
              !envKey.isEmpty else {
            throw ClientError.noSpreedlyCredentials
        }

        return ClientConfiguration(
                envKey: envKey,
                test: config["TEST"] as? Bool ?? false,
                testCardNumber: config["TEST_CARD_NUMBER"] as? String
        )
    }
}
// swiftlint:enable line_length

@objc(SPRClientError)
public enum ClientError: Int, Error {
    case noSpreedlyCredentials
    case parseError
    case invalidRequestData
}
