//
// Created by Eli Thompson on 5/29/20.
//

import Spreedly

/// Allows this control to return it's text property as a SpreedlySecureOpaqueString.
/// Recommended for use with card verification value.
@objc(SPRSecureTextField)
public class SecureTextField: ValidatedTextField {
    /// Returns the text value of this field as a SpreedlySecureOpaqueString.
    @objc open func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = self.text else {
            return nil
        }
        return SpreedlySecureOpaqueStringBuilder.build(from: text)
    }
}
