//
// Created by Eli Thompson on 5/25/20.
//

import Foundation
import UIKit

@objc(SPRValidationState)
public enum ValidationState: Int {
    case none
    case valid
    case error
}

/// A UITextField which is aware of its validation state and updates its appearance commensurately.
@objc(SPRValidatedTextField)
open class ValidatedTextField: UITextField {
    private weak var userDelegate: UITextFieldDelegate?
    lazy var statusIcon: UIImageView = {
        UIImageView(frame: .zero)
    }()

    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func setup() {
        super.delegate = self
        addStatusIcon()
    }

    private func addStatusIcon() {
        addSubview(statusIcon)
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7)
        ])
    }

    /// Gets the current validation state.
    @objc public private(set) var validationState: ValidationState = .none

    /// The reason this control is in error.
    @objc public var reason: String?

    /// Puts the control into an undetermined validation state.
    @objc public func clearValidation() {
        validationState = .none
        reason = nil
        updateDisplay()
    }

    /// Puts the control into an error state.
    /// - Parameter reason: A human readable reason for the error.
    @objc public func setError(because reason: String) {
        validationState = .error
        self.reason = reason
        updateDisplay()
    }

    /// Puts the control into a valid state.
    @objc public func setValid() {
        validationState = .valid
        reason = nil
        updateDisplay()
    }

    private func updateDisplay() {
        switch validationState {
        case .none:
            backgroundColor = UIColor.clear
            statusIcon.image = nil
        case .valid:
            backgroundColor = UIColor.clear
            statusIcon.image = UIImage.initPre13(systemName: "checkmark.circle", fallbackEmoji: "✅")
            statusIcon.tintColor = UIColor.systemGreen
        case .error:
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusIcon.image = UIImage.initPre13(systemName: "exclamationmark.circle", fallbackEmoji: "⛔")
            statusIcon.tintColor = UIColor.systemRed
        }
    }
}

extension ValidatedTextField: UITextFieldDelegate {
    @objc public override var delegate: UITextFieldDelegate? {
        get {
            userDelegate
        }
        set {
            userDelegate = newValue
        }
    }

    /// Any time the user causes the text to change, reset the validation state.
    @objc public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
    ) -> Bool {
        clearValidation()
        return self.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
