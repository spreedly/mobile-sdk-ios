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
