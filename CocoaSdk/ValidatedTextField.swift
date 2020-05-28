//
// Created by Eli Thompson on 5/25/20.
//

import Foundation
import UIKit

public class ValidatedTextField: UITextField {
    public required init?(coder: NSCoder) {
        self.defaultColor = UIColor.label
        self.errorColor = UIColor.red
        self.defaultBorderColor = UIColor.clear
        self.errorBorderColor = UIColor.red

        super.init(coder: coder)
    }

    public override init(frame: CGRect) {
        self.defaultColor = UIColor.label
        self.errorColor = UIColor.red
        self.defaultBorderColor = UIColor.clear
        self.errorBorderColor = UIColor.red

        super.init(frame: frame)
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

    public var invalidationReason: String?

    public func invalidate(because reason: String) {
        invalidationReason = reason
        validState = false
        updateColor()
    }

    public func validate() {
        invalidationReason = nil
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
