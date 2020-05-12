//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation

public struct Address {
    public var address1: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var zip: String?
    public var country: String?
    public var phoneNumber: String?

    public enum AddressType {
        case billing
        case shipping
    }

    public init() {
    }

    init?(from json: [String: Any], as type: AddressType) {
        let prefix = self.prefix(for: type)

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
        let prefix = self.prefix(for: type)

        result.maybeSet("\(prefix)address1", address1)
        result.maybeSet("\(prefix)address2", address2)
        result.maybeSet("\(prefix)city", city)
        result.maybeSet("\(prefix)state", state)
        result.maybeSet("\(prefix)zip", zip)
        result.maybeSet("\(prefix)country", country)
        result.maybeSet("\(prefix)phone_number", phoneNumber)
    }

    private func prefix(for type: AddressType) -> String {
        switch type {
        case .billing:
            return ""
        case .shipping:
            return "shipping_"
        }
    }
}
