//
// Created by Eli Thompson on 7/21/20.
//

import Foundation
import UIKit

extension UIActivityIndicatorView.Style {
    static let largePre13: UIActivityIndicatorView.Style = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView.Style.large
        } else {
            return UIActivityIndicatorView.Style.white
        }
    }()
}

extension UIColor {
    static let labelPre13: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }()

    static let systemBackgroundPre13: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()

    static let tertiarySystemBackgroundPre13: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.tertiarySystemBackground
        } else {
            return UIColor.white
        }
    }()

    static let separatorPre13: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.separator
        } else {
            return UIColor(red: 60.0, green: 60.0, blue: 67.0, alpha: 0.29)
        }
    }()

}
