//
//  ClientFactory.swift
//  Spreedly
//
//  Created by Eli Thompson on 6/10/20.
//

import Foundation

@objc(SPRClientFactory)
public class ClientFactory: NSObject {
    public static func create(with config: ClientConfiguration) -> SpreedlyClient {
        SpreedlyClientImpl(with: config)
    }

    @objc(createWithConfig:)
    public static func _objCCreate(with config: ClientConfiguration) -> _ObjCClient { // swiftlint:disable:this identifier_name line_length
        SpreedlyClientImpl(with: config)
    }
}

@objc(SPRClientConfiguration)
public class ClientConfiguration: NSObject {
    @objc public let envKey: String
    @objc public var envSecret: String?
    @objc public var test: Bool = false
    @objc public var testCardNumber: String?

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
                envSecret: config["ENV_SECRET"] as? String,
                test: config["TEST"] as? Bool ?? false,
                testCardNumber: config["TEST_CARD_NUMBER"] as? String
        )
    }
}

@objc(SPRClientError)
public enum ClientError: Int, Error {
    case noSpreedlyCredentials
}
