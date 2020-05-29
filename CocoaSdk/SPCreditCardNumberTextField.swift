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

    private var rawText: String? {
        masked ? unmaskedText : text
    }

    public override func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = rawText else {
            return nil
        }
        let cardNumber = text.onlyNumbers()
        let client = getClient()
        return client?.createSecureString(from: cardNumber)
    }

    public func formatCardNumber(_ string: String) -> String {
        var formattedString = String()
        let cardNumber = string.withoutSpaces()
        for (index, character) in cardNumber.enumerated() {
            if index != 0 && index % 4 == 0 {
                formattedString.append(" ")
            }

            formattedString.append(character)
        }

        return formattedString
    }
}

// MARK: - UITextFieldDelegate methods
extension SPCreditCardNumberTextField {
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
        guard let cardNumber = text?.onlyNumbers() else {
            return ""
        }

        if let foo = cardNumber.index(cardNumber.endIndex, offsetBy: -4, limitedBy: cardNumber.startIndex) {
            return String(cardNumber[foo...])
        } else {
            return cardNumber
        }
    }

    private func applyMask() {
        guard !masked,
              let rawNumber = text else {
            return
        }

        unmaskedText = rawNumber
        let cardNumber = rawNumber.onlyNumbers()
        let maskCharacterCount = max(cardNumber.count - 4, 0)

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

    public override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !super.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return false
        }

        guard string.count > 0 else {
            // allow backspace/delete
            return true
        }

        let current = textField.text ?? ""

        let cleaned = string.onlyNumbers()
        guard cleaned.count > 0 else {
            // none of the replacementString was useful
            return false
        }

        let requested = "\(current)\(cleaned)"

        guard requested.count <= "1234 5678 1234 5678".count else {
            // too many characters are coming in
            return false
        }

        textField.text = formatCardNumber(requested)
        return false
    }
}
