//
// Created by Eli Thompson on 5/29/20.
//

import Spreedly

public class SPSecureTextField: ValidatedTextField {
    /// Returns the text value of this field as a SpreedlySecureOpaqueString.
    open func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = self.text else {
            return nil
        }
        return SpreedlySecureOpaqueStringBuilder.build(from: text)
    }
}
