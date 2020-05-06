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
        let prefix = {
            switch type {
            case .billing:
                ""
            case .shipping:
                "shipping_"
            }
        }()

        if let address1 = json["\(prefix)address1"] as? String {
            self.address1 = address1
            address2 = json["\(prefix)address2"] as? String
            city = json["\(prefix)city"] as? String
            state = json["\(prefix)state"] as? String
            zip = json["\(prefix)zip"] as? String
            country = json["\(prefix)country"] as? String
            phoneNumber = json["\(prefix)phoneNumber"] as? String
        } else {
            return nil
        }
    }
}
