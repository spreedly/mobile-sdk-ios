//
// Created by Eli Thompson on 5/26/20.
//

import Foundation
import UIKit
import CoreSdk

public protocol CardBrandDeterminationDelegate {
    func cardBrandDetermination(brand: CardBrand)
}

public class SPCreditCardNumberTextField: SPSecureTextField {
    @IBInspectable public var maskCharacter: String = "*"

    public var cardTypeDeterminationDelegate: CardBrandDeterminationDelegate?
    private var unmaskedText: String?
    private var masked: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.delegate = self
    }

    public override func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = self.unmaskedText else {
            return nil
        }
        let onlyNumbers = text.replacingOccurrences(of: " ", with: "")
        let client = getClient()
        return client?.createSecureString(from: onlyNumbers)
    }

    public func formatCardNumber(_ string: String) -> String {
        var formattedString = String()
        let normalizedString = string.replacingOccurrences(of: " ", with: "")
        for (index, character) in normalizedString.enumerated() {
            if index != 0 && index % 4 == 0 {
                formattedString.append(" ")
            }

            formattedString.append(character)
        }

        return formattedString
    }

    private func normalizeNumber(_ number: String?) -> String {
        guard let number = number else {
            return ""
        }
        return String(number.filter { $0.isNumber })
    }
}

extension SPCreditCardNumberTextField: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField, reason: DidEndEditingReason) {
        let cardBrand = CardBrand.from(textField.text)
        cardTypeDeterminationDelegate?.cardBrandDetermination(brand: cardBrand)
        applyMask()
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        removeMask()
        return true
    }

    private var lastFour: String {
        guard let cardNumber = text else {
            return ""
        }

        let cleanedNumber = normalizeNumber(cardNumber)

        if let foo = cleanedNumber.index(cleanedNumber.endIndex, offsetBy: -4, limitedBy: cleanedNumber.startIndex) {
            return String(cleanedNumber[foo...])
        } else {
            return cleanedNumber
        }
    }

    private func applyMask() {
        guard !masked,
              let rawNumber = text else {
            return
        }

        unmaskedText = rawNumber
        let cleanedNumber = normalizeNumber(rawNumber)
        let maskCharacterCount = max(cleanedNumber.count - 4, 0)

        let mask = String(repeating: maskCharacter, count: maskCharacterCount)
        text = formatCardNumber(mask + lastFour)
        masked = true
    }

    private func removeMask() {
        guard masked else {
            return
        }

        text = unmaskedText ?? ""
        masked = false
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        unsetError()

        guard string.count > 0 else {
            // allow backspace/delete
            return true
        }

        let current = textField.text ?? ""

        let cleaned = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleaned.count > 0 else {
            // none of the replacementString was useful
            return false
        }

        let requested = "\(current)\(string)"

        guard requested.count <= "1234 5678 1234 5678".count else {
            // too many characters are coming in
            return false
        }

        textField.text = formatCardNumber(requested)
        return false
    }
}
