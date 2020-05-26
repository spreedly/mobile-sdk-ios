//
// Created by Eli Thompson on 5/26/20.
//

import Foundation
import UIKit
import FormTextField
import CoreSdk

public class SPCreditCardNumberTextField: SPSecureTextField, UITextFieldDelegate {
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.delegate = self
    }

    public override var formatter: Formattable? {
        CardNumberFormatter()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }

        let current = textField.text ?? ""

        print("Current: \(textField.text ?? "")")
        print("Replacement string: \(string)")

        if current.count + string.count > "1234 5678 1234 5678".count {
            return false
        }

        let requested = "\(textField.text ?? "")\(string)"
        textField.text = formatter?.formatString(requested, reverse: false)

        return false
    }

    public override func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = self.text else {
            return nil
        }
        let client = getClient()
        return client?.createSecureString(from: text.replacingOccurrences(of: " ", with: ""))
    }
}
