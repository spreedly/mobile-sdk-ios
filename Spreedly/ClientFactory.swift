//
//  ClientFactory.swift
//  Spreedly
//
//  Created by Eli Thompson on 6/10/20.
//

import Foundation

@objc(SPRClientFactory)
public class ClientFactory: NSObject {
    /// Creates a concrete instance of a `SpreedlyClient` using the given `ClientConfiguration`.
    public static func create(with config: ClientConfiguration) -> SpreedlyClient {
        SpreedlyClientImpl(with: config)
    }

    /// Creates a concrete instance of a `SpreedlyClient` using the given `ClientConfiguration`.
    @objc(createWithConfig:)
    public static func _objCCreate(with config: ClientConfiguration) -> _ObjCClient { // swiftlint:disable:this identifier_name line_length
        SpreedlyClientImpl(with: config)
    }
}
