//
// Created by Eli Thompson on 5/26/20.
//

import Foundation
import UIKit
import Spreedly

public protocol CreditCardNumberTextFieldDelegate: class {
    func cardBrandDetermined(brand: CardBrand)
}

@objc(SPRCreditCardNumberTextField)
public class CreditCardNumberTextField: SecureTextField {
    static private let unknownCard: String = "spr_card_unknown"
    @IBInspectable public var maskCharacter: String = "*"

    public weak var cardNumberTextFieldDelegate: CreditCardNumberTextFieldDelegate?
    private var unmaskedText: String?
    private var masked: Bool = false
    private let image = UIImageView(image: UIImage(named: CreditCardNumberTextField.unknownCard))

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)

        addBrandImage()
    }

    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)

        addBrandImage()
    }

    private func addBrandImage() {
        addSubview(image)

        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -7)
        ])
    }

    func imageFromBundle(named name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            print("Found image named \(name) in default bundle.")
            return image
        }
        let containingBundle = Bundle(for: CreditCardNumberTextField.self)
        if let image = UIImage(named: name, in: containingBundle, with: nil) {
            print("Found image named \(name) in containing bundle.")
            return image
        }
        if let resourcePath = containingBundle.path(forResource: "SpreedlyCocoaResources", ofType: "bundle"),
           let resourceBundle = Bundle(path: resourcePath),
           let image = UIImage(named: name, in: resourceBundle, with: nil) {
            print("Found image named \(name) in resource bundle.")
            return image
        }
        print("Unable to find image named \(name) in bundles :(")
        return nil
    }

    private func updateCardBrandImage(brand: CardBrand) {

        let image = self.imageFromBundle(named: "spr_card_\(brand)")
                ?? self.imageFromBundle(named: CreditCardNumberTextField.unknownCard)

//        let image = UIImage(named: "spr_card_\(brand)") ?? UIImage(named: CreditCardNumberTextField.unknownCard)
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

    func formatCardNumber(_ string: String) -> String {
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
extension CreditCardNumberTextField {
    @discardableResult
    private func determineCardBrand(_ number: String) -> CardBrand {
        let cardBrand = CardBrand.from(number)
        self.updateCardBrandImage(brand: cardBrand)

        DispatchQueue.global(qos: .default).async {
            self.cardNumberTextFieldDelegate?.cardBrandDetermined(brand: cardBrand)
        }

        return cardBrand
    }

    @objc public func textFieldDidEndEditing(_ textField: UITextField, reason: DidEndEditingReason) {
        determineCardBrand(textField.text ?? "")
        applyMask()
    }

    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        removeMask()
    }

    func generateMasked(from string: String) -> String {
        let cardNumber = string.onlyNumbers()
        let maskCharacterCount = max(cardNumber.count - 4, 0)

        let mask = String(repeating: maskCharacter, count: maskCharacterCount)
        let lastFour = cardNumber.suffix(4)
        return mask + lastFour
    }

    private func applyMask() {
        guard !masked,
              let rawNumber = text else {
            return
        }

        unmaskedText = rawNumber
        let maskedNumber = generateMasked(from: rawNumber)

        text = formatCardNumber(maskedNumber)
        masked = true
    }

    private func removeMask() {
        guard masked else {
            return
        }

        text = unmaskedText ?? ""
        masked = false
    }

    func cleanAndReplace(current: String, range: NSRange, replacementString string: String) -> String? {
        let cleaned = string.onlyNumbers()
        guard string.count == 0 || cleaned.count > 0 else {
            // none of the replacementString was useful
            return nil
        }

        let requested = current.replacing(range: range, with: cleaned)
        let brand = CardBrand.from(requested)

        guard requested.onlyNumbers().count <= brand.maxLength else {
            // too many characters are coming in
            return nil
        }

        return requested
    }

    public override func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
    ) -> Bool {
        guard super.textField(textField, shouldChangeCharactersIn: range, replacementString: string) else {
            return false
        }

        if let requested = cleanAndReplace(current: textField.text ?? "", range: range, replacementString: string) {
            textField.text = formatCardNumber(requested)
            determineCardBrand(requested)
        }
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
