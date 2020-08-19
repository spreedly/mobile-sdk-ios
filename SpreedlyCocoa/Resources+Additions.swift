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
        UIImage(named: name, in: BundleLocator.resources, compatibleWith: nil) ?? UIImage(named: name)
    }

    static func canLoadFromResources(named name: String) -> Bool {
        fromResources(named: name) != nil
    }
}

extension UIStoryboard {
    /// Searches for the `UIStoryboard` with the given name in the resources, spreedly, and main bundles in order.
    static func fromResources(named name: String) -> UIStoryboard? {
        let bundles = [BundleLocator.resources, BundleLocator.spreedly, Bundle.main]
        guard let bundle = search(bundles: bundles, forResource: name, ofType: "storyboardc") else {
            return nil
        }
        return UIStoryboard(name: name, bundle: bundle)
    }

    /// Returns the first bundle containing the sought resource.
    private static func search(bundles: [Bundle?], forResource name: String, ofType ext: String) -> Bundle? {
        bundles.compactMap { bundle -> Bundle? in
            if bundle?.path(forResource: name, ofType: ext) != nil {
                return bundle
            } else {
                return nil
            }
        }.first
    }
}
