//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

@objc class SpreedlyClientImpl: NSObject, SpreedlyClient {
    let env: String
    let secret: String

    init(env: String, secret: String) {
        self.env = env
        self.secret = secret
        super.init()
    }

    func createSecureString() -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl();
    }

    func createSecureString(from source: String) -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl(from: source);
    }
}
