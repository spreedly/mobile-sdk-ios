//
// Created by Eli Thompson on 7/8/20.
//

import Foundation

@objc(SPRClientConfiguration)
public class ClientConfiguration: NSObject {
    @objc public let envKey: String
    @objc public let envSecret: String?
    @objc public let test: Bool
    @objc public let testCardNumber: String?

    @objc public init(envKey: String, envSecret: String? = nil, test: Bool = false, testCardNumber: String? = nil) {
        self.envKey = envKey
        self.envSecret = envSecret
        self.test = test
        self.testCardNumber = testCardNumber
    }

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

@objc(SPRClientError)
public enum ClientError: Int, Error {
    case noSpreedlyCredentials
}
