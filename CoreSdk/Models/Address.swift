//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation

public class Address: NSObject {
    @objc public var address1: String?
    @objc public var address2: String?
    @objc public var city: String?
    @objc public var state: String?
    @objc public var zip: String?
    @objc public var country: String?
    @objc public var phoneNumber: String?

    public enum AddressType {
        case billing
        case shipping

        var prefix: String {
            switch self {
            case .billing:
                return ""
            case .shipping:
                return "shipping_"
            }
        }
    }

    init?(from json: [String: Any], as type: AddressType) {
        let prefix = type.prefix

        guard let address1 = json.string(optional: "\(prefix)address1") else {
            return nil
        }

        self.address1 = address1
        address2 = json.string(optional: "\(prefix)address2")
        city = json.string(optional: "\(prefix)city")
        state = json.string(optional: "\(prefix)state")
        zip = json.string(optional: "\(prefix)zip")
        country = json.string(optional: "\(prefix)country")
        phoneNumber = json.string(optional: "\(prefix)phone_number")
    }

    func toJson(_ result: inout [String: Any], _ type: AddressType) {
        let prefix = type.prefix

        result.maybeSet("\(prefix)address1", address1)
        result.maybeSet("\(prefix)address2", address2)
        result.maybeSet("\(prefix)city", city)
        result.maybeSet("\(prefix)state", state)
        result.maybeSet("\(prefix)zip", zip)
        result.maybeSet("\(prefix)country", country)
        result.maybeSet("\(prefix)phone_number", phoneNumber)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Address else {
            return false
        }
        return self.address1 == other.address1
                && self.address2 == other.address2
                && self.city == other.city
                && self.state == other.state
                && self.zip == other.zip
                && self.country == other.country
                && self.phoneNumber == other.phoneNumber
    }
}
