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

    @objc(createWithEnvKey:envSecret:test:)
    public static func _objCCreate(envKey: String, envSecret: String, test: Bool) -> _ObjCClient { // swiftlint:disable:this identifier_name line_length
        SpreedlyClientImpl(envKey: envKey, envSecret: envSecret, test: test)
    }
}
