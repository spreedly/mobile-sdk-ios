//
// Created by Eli Thompson on 5/25/20.
//

import Foundation
import UIKit

public enum ValidationState {
    case none
    case valid
    case error
}

public class ValidatedTextField: UITextField {
    private weak var userDelegate: UITextFieldDelegate?
    lazy var statusIcon: UIImageView = {
        UIImageView(frame: .zero)
    }()

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    public override init(frame: CGRect) {
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

    public private(set) var validationState: ValidationState = .none

    public var reason: String?

    public func clearValidation() {
        validationState = .none
        reason = nil
        updateDisplay()
    }

    public func setError(because reason: String) {
        validationState = .error
        self.reason = reason
        updateDisplay()
    }

    public func setValid() {
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
            statusIcon.image = UIImage(systemName: "checkmark.circle")
            statusIcon.tintColor = UIColor.systemGreen
        case .error:
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusIcon.image = UIImage(systemName: "exclamationmark.circle")
            statusIcon.tintColor = UIColor.systemRed
        }
    }
}

extension ValidatedTextField: UITextFieldDelegate {
    public override var delegate: UITextFieldDelegate? {
        get {
            userDelegate
        }
        set {
            userDelegate = newValue
        }
    }

    public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
    ) -> Bool {
        clearValidation()
        return self.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
