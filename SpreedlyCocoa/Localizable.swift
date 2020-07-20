//
// Created by Eli Thompson on 6/30/20.
//

import UIKit

protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    var localized: String {
        NSLocalizedString(self, bundle: BundleLocator.resources ?? Bundle.main, comment: "")
    }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get {
            nil
        }
        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get {
            nil
        }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}

extension UINavigationItem: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get {
            nil
        }
        set(key) {
            title = key?.localized
        }
    }
}

public protocol UITextFieldXIBLocalizable {
    var xibPlaceholderLocKey: String? { get set }
}

extension UITextField: UITextFieldXIBLocalizable {
    @IBInspectable public var xibPlaceholderLocKey: String? {
        get {
            nil
        }
        set(key) {
            placeholder = key?.localized
        }
    }
}

public protocol XIBMultiLocalizable {
    var xibLocKeys: String? { get set }
}

extension UISegmentedControl: XIBMultiLocalizable {
    @IBInspectable public var xibLocKeys: String? {
        get {
            nil
        }
        set(keys) {
            guard let keys = keys?.components(separatedBy: ","), !keys.isEmpty else {
                return
            }
            for (index, title) in keys.enumerated() {
                setTitle(title.localized, forSegmentAt: index)
            }
        }
    }
}
