//
// Created by Eli Thompson on 7/21/20.
//

import Foundation
import UIKit

extension UIImage {
    /// Attempt to get the named image from the resources bundle.
    /// Fallback to the main bundle if not found.
    /// - Parameter name: The name of the image.
    /// - Returns: The appropriate image if found, otherwise nil.
    static func fromResources(named name: String) -> UIImage? {
        UIImage(named: name, in: BundleLocator.resources, with: nil) ?? UIImage(named: name)
    }
}
