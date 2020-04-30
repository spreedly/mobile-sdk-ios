//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

@objc class SpreedlyClientImpl: NSObject, SpreedlyClient {
    func createSecureString() -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl();
    }

    func createSecureString(from source: String) -> SpreedlySecureOpaqueString {
        SpreedlySecureOpaqueStringImpl(from: source);
    }
}
