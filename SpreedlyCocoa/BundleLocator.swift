//
// Created by Eli Thompson on 7/21/20.
//

import Foundation
import os

class BundleLocator {
    static let resourceBundleName: String = "SpreedlyCocoaResources"

    static var spreedly: Bundle = {
        Bundle(for: BundleLocator.self)
    }()

    static var resources: Bundle? = {
        guard let resourcePath = spreedly.path(forResource: BundleLocator.resourceBundleName, ofType: "bundle"),
              let resourceBundle = Bundle(path: resourcePath) else {
            os_log("Unable to find resource bundle.", type: .info)
            return nil
        }
        os_log("Found resource bundle at path %s.", type: .info, resourcePath)
        return resourceBundle
    }()

    /// When the resource bundle includes the main bundle's preferred localization, return it.
    /// Otherwise, return the main bundle.
    /// This allows integrators to provide their own translations when we don't provide one.
    static var localization: Bundle = {
        guard let resources = resources else {
            os_log("Unable to find resource bundle. Localizations will use main.", type: .info)
            return Bundle.main
        }
        let firstPreferredLocalization = Bundle.main.preferredLocalizations.first ?? "n/a"
        if resources.preferredLocalizations.first == firstPreferredLocalization {
            os_log("Resources bundle supports %s", type: .info, firstPreferredLocalization)
            return resources
        } else {
            os_log("Resources bundle does not support %s", type: .info, firstPreferredLocalization)
            return Bundle.main
        }
    }()
}
