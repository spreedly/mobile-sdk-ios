//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

/// Spreedly core client
@objc protocol SpreedlyClient {
    /// creates a secure string
    ///
    /// This class is used by various calls to expose a mutable string that
    /// can't be easily read or stored in local data stores.
    ///
    /// - Returns: an empty SpreedlySecureOpaqueString.
    func createSecureString() -> SpreedlySecureOpaqueString;

    /// creates a secure string
    ///
    /// This class is used by various calls to expose a mutable string that
    /// can't be easily read or stored in local data stores.
    ///
    /// - Returns: a SpreedlySecureOpaqueString with the specified contents.
    func createSecureString(from source: String) -> SpreedlySecureOpaqueString;
}

@objc protocol SpreedlySecureOpaqueString {

    func clear();

    func append(string s: String);

    func removeLastCharacter();
}
