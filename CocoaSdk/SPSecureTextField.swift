//
// Created by Eli Thompson on 5/29/20.
//

import CoreSdk

public class SPSecureTextField: ValidatedTextField {
    /// Returns the text value of this field as a SpreedlySecureOpaqueString.
    open func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = self.text else {
            return nil
        }
        let client = getClient()
        return client?.createSecureString(from: text)
    }

    /// Returns the SpreedlyClient from the first SPSecureForm ancestor.
    func getClient() -> SpreedlyClient? {
        var view = self.superview

        while view != nil {
            if let form = view as? SPSecureForm {
                return try? form.getClient()
            }
            view = view?.superview
        }

        return nil
    }
}
