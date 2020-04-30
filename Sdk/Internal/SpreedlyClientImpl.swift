//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

@obj class SpreedlyClientImpl: NSObject, SpreedlyClient {
    func createSecureString() -> SpreedlySecureOpaqueString {
        return SpreedlySecureOpaqueStringImpl();
    }

    func createSecureString(from source: String) -> SpreedlySecureOpaqueString {
        return SpreedlyClientImpl(from: source);
    }

}
