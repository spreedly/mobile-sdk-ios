//
// Created by Eli Thompson on 5/26/20.
//

import Foundation
import UIKit
import FormTextField

public class SPExpirationTextField: ValidatedTextField, UITextFieldDelegate {
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.delegate = self
    }

    public override var formatter: Formattable? {
        CardExpirationDateFormatter()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        unsetError()

        guard string.count > 0 else {
            // allow backspace/delete
            return true
        }

        var current = textField.text ?? ""

        if string == "/" &&  current.count == 1 {
            // user gave us a backslash with a single digit month
            current = "0\(current)"
            textField.text = formatter?.formatString(current, reverse: false)
            return false
        }

        let cleaned = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleaned.count > 0 else {
            // none of the replacementString was useful
            return false
        }

        let requested = "\(current)\(cleaned)"
        guard requested.count <= "MM/yy".count else {
            // too many characters are coming in
            return false
        }

        textField.text = formatter?.formatString(requested, reverse: false)
        return false
    }

    public func dateParts() -> (month: Int?, year: Int?)? {
        guard let text = self.text, text.count == "MM/yy".count else {
            return nil
        }

        let parts = text.split(separator: "/").map { Int($0) }
        return (month: parts[0], year: 2000 + (parts[1] ?? 0))
    }
}
