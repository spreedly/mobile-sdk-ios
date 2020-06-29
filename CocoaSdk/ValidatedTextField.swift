//
// Created by Eli Thompson on 5/25/20.
//

import Foundation
import UIKit

public class ValidatedTextField: UITextField {
    private weak var userDelegate: UITextFieldDelegate?

    public required init?(coder: NSCoder) {
        self.defaultColor = UIColor.label
        self.errorColor = UIColor.red
        self.defaultBorderColor = UIColor.clear
        self.errorBorderColor = UIColor.red

        super.init(coder: coder)

        super.delegate = self
    }

    public override init(frame: CGRect) {
        self.defaultColor = UIColor.label
        self.errorColor = UIColor.red
        self.defaultBorderColor = UIColor.clear
        self.errorBorderColor = UIColor.red

        super.init(frame: frame)

        super.delegate = self
    }

    @IBInspectable
    public var defaultColor: UIColor {
        didSet {
            updateColor()
        }
    }

    @IBInspectable
    public var errorColor: UIColor {
        didSet {
            updateColor()
        }
    }


    @IBInspectable
    public var defaultBorderColor: UIColor {
        didSet {
            updateColor()
        }
    }

    @IBInspectable
    public var errorBorderColor: UIColor {
        didSet {
            updateColor()
        }
    }

    public private(set) var validState: Bool = true

    public var reason: String?

    public func setError(because reason: String) {
        self.reason = reason
        validState = false
        updateColor()
    }

    public func unsetError() {
        reason = nil
        validState = true
        updateColor()
    }

    private func updateColor() {
        textColor = validState ? defaultColor : errorColor

        layer.borderColor = (
                validState ?
                        defaultBorderColor.cgColor :
                        errorBorderColor.cgColor
        )
        layer.borderWidth = validState ? 0.0 : 1.0
    }
}

extension ValidatedTextField: UITextFieldDelegate {
    public override var delegate: UITextFieldDelegate? {
        get { userDelegate }
        set { userDelegate = newValue }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        unsetError()

        return self.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
