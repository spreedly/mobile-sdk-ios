//
// Created by Eli Thompson on 5/26/20.
//

import Foundation
import UIKit
import CoreSdk

public protocol SPCreditCardNumberTextFieldDelegate {
    func cardBrandDetermined(brand: CardBrand)
}

public class SPCreditCardNumberTextField: SPSecureTextField {
    static private let unknownCard: String = "spr_card_unknown"
    @IBInspectable public var maskCharacter: String = "*"

    public var cardNumberTextFieldDelegate: SPCreditCardNumberTextFieldDelegate?
    private var unmaskedText: String?
    private var masked: Bool = false
    private let image = UIImageView(image: UIImage(named: SPCreditCardNumberTextField.unknownCard))

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.trailingAnchor.anchorWithOffset(to: trailingAnchor).constraint(equalToConstant: 7).isActive = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.trailingAnchor.anchorWithOffset(to: trailingAnchor).constraint(equalToConstant: 7).isActive = true
    }

    func cardBrandDetermined(brand: CardBrand) {
        let image = UIImage(named: "spr_card_\(brand)") ?? UIImage(named: SPCreditCardNumberTextField.unknownCard)
        self.image.image = image
    }

    private var rawText: String? {
        masked ? unmaskedText : text
    }

    public override func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = rawText else {
            return nil
        }
        let cardNumber = text.onlyNumbers()
        return SpreedlySecureOpaqueStringBuilder.build(from: cardNumber)
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
    @discardableResult
    func determineCardBrand(_ number: String) -> CardBrand {
        let cardBrand = CardBrand.from(number)
        self.cardBrandDetermined(brand: cardBrand)
        cardNumberTextFieldDelegate?.cardBrandDetermined(brand: cardBrand)
        return cardBrand
    }

    public func textFieldDidEndEditing(_ textField: UITextField, reason: DidEndEditingReason) {
        determineCardBrand(textField.text ?? "")
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

        if let lastFourStartIndex = cardNumber.index(
                cardNumber.endIndex,
                offsetBy: -4,
                limitedBy: cardNumber.startIndex
        ) {
            return String(cardNumber[lastFourStartIndex...])
        } else {
            // there must be less than 4 digits so return what there is
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
        guard super.textField(textField, shouldChangeCharactersIn: range, replacementString: string) else {
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

        let brand = determineCardBrand(current)

        let requested = "\(current)\(cleaned)"

        guard requested.onlyNumbers().count <= brand.maxLength else {
            // too many characters are coming in
            return false
        }

        textField.text = formatCardNumber(requested)
        determineCardBrand(requested)
        return false
    }
}
