//
//  ClientFactory.swift
//  Spreedly
//
//  Created by Eli Thompson on 6/10/20.
//

import Foundation

@objc(SPRClientFactory)
public class ClientFactory: NSObject {
    public static func create(envKey: String, envSecret: String, test: Bool = false) -> SpreedlyClient {
        SpreedlyClientImpl(envKey: envKey, envSecret: envSecret, test: test)
    }

    public static func create(credentials: Credentials) -> SpreedlyClient {
        ClientFactory.create(envKey: credentials.envKey, envSecret: credentials.envSecret, test: credentials.test)
    }

    @objc(createWithEnvKey:envSecret:test:)
    public static func _objCCreate(envKey: String, envSecret: String, test: Bool) -> _ObjCClient { // swiftlint:disable:this identifier_name line_length
        SpreedlyClientImpl(envKey: envKey, envSecret: envSecret, test: test)
    }
}

@objc(SPRCredentials)
public class Credentials: NSObject {
    @objc public let envKey: String
    @objc public let envSecret: String
    @objc public let test: Bool

    init(envKey: String, envSecret: String, test: Bool) {
        self.envKey = envKey
        self.envSecret = envSecret
        self.test = test
    }

    @objc public static func getCredentials() throws -> Credentials {
        guard let path = Bundle.main.path(forResource: "Spreedly-env", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let envKey = config["ENV_KEY"] as? String,
              let envSecret = config["ENV_SECRET"] as? String,
              envKey.count > 0 && envSecret.count > 0 else {
            throw ClientError.noSpreedlyCredentials
        }

        return Credentials(
                envKey: envKey,
                envSecret: envSecret,
                test: config["TEST"] as? Bool ?? false
        )
    }
}

@objc(SPRClientError)
public enum ClientError: Int, Error {
    case noSpreedlyCredentials
}
