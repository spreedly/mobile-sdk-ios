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

        addBrandImage()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        addBrandImage()
    }

    private func addBrandImage() {
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.trailingAnchor.anchorWithOffset(to: trailingAnchor).constraint(equalToConstant: 7).isActive = true
    }

    func updateCardBrandImage(brand: CardBrand) {
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
        self.updateCardBrandImage(brand: cardBrand)

        DispatchQueue.global(qos: .default).async {
            self.cardNumberTextFieldDelegate?.cardBrandDetermined(brand: cardBrand)
        }

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

    private func applyMask() {
        guard !masked,
              let rawNumber = text else {
            return
        }

        unmaskedText = rawNumber
        let cardNumber = rawNumber.onlyNumbers()
        let maskCharacterCount = max(cardNumber.count - 4, 0)

        let mask = String(repeating: maskCharacter, count: maskCharacterCount)
        let lastFour = cardNumber.suffix(4)
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

        let cleaned = string.onlyNumbers()
        guard string.count == 0 || cleaned.count > 0 else {
            // none of the replacementString was useful
            return false
        }

        let current = textField.text ?? ""
        let requested = current.replacing(range: range, with: cleaned)
        let brand = CardBrand.from(requested)

        guard requested.onlyNumbers().count <= brand.maxLength else {
            // too many characters are coming in
            return false
        }

        textField.text = formatCardNumber(requested)
        determineCardBrand(requested)
        return false
    }
}

fileprivate extension String {
    func replacing(range: NSRange, with string: String) -> String {
        var result = self
        let startEdit = result.index(result.startIndex, offsetBy: range.location)
        let endEdit = result.index(startEdit, offsetBy: range.length)
        result.replaceSubrange(startEdit..<endEdit, with: string)
        return result
    }
}
