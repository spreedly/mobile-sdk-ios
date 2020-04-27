public struct CreditCard: Codable, CustomStringConvertible {
    public var firstName: String = ""
    public var lastName: String = ""
    public var number: String = ""
    public var verificationValue: String = ""
    public var month: String = ""
    public var year: String = ""
    public var company: String? = nil
    public var address1: String? = nil
    public var address2: String? = nil
    public var city: String? = nil
    public var state: String? = nil
    public var zip: String? = nil
    public var country: String? = nil
    public var phoneNumber: String? = nil
    public var shippingAddress1: String? = nil
    public var shippingAddress2: String? = nil
    public var shippingCity: String? = nil
    public var shippingState: String? = nil
    public var shippingZip: String? = nil
    public var shippingCountry: String? = nil
    public var shippingPhoneNumber: String? = nil

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case number
        case verificationValue = "verification_value"
        case month
        case year
        case company
        case address1
        case address2
        case city
        case state
        case zip
        case country
        case phoneNumber = "phone_number"
        case shippingAddress1 = "shipping_address1"
        case shippingAddress2 = "shipping_address2"
        case shippingCity = "shipping_city"
        case shippingState = "shipping_state"
        case shippingZip = "shipping_zip"
        case shippingCountry = "shipping_country"
        case shippingPhoneNumber = "shipping_phone_number"
    }

//    public init(
//            firstName: String,
//            lastName: String,
//            number: String,
//            verificationValue: String,
//            month: String,
//            year: String,
//            company: String? = nil,
//            address1: String? = nil,
//            city: String? = nil,
//            state: String? = nil,
//            zip: String? = nil,
//            country: String? = nil,
//            phoneNumber: String? = nil,
//            shippingAddress1: String? = nil,
//            shippingAddress2: String? = nil,
//            shippingCity: String? = nil,
//            shippingState: String? = nil,
//            shippingZip: String? = nil,
//            shippingCountry: String? = nil,
//            shippingPhoneNumber: String? = nil
//    ) {
//        self.firstName = firstName
//        self.lastName = lastName
//        self.number = number
//        self.verificationValue = verificationValue
//        self.month = month
//        self.year = year
//        self.company = company
//    }


    private var bin: String {
        "\(number.prefix(6))"
    }

    private var last4: String {
        "\(number.suffix(4))"
    }

    private var viewableNumber: String {
        "\(bin)...\(last4)"
    }

    public var description: String {
        "CreditCard(\(viewableNumber))"
    }

    public init() { }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.number = try container.decode(String.self, forKey: .number)
        self.verificationValue = try container.decode(String.self, forKey: .verificationValue)
        self.month = try container.decode(String.self, forKey: .month)
        self.year = try container.decode(String.self, forKey: .year)
        self.company = try container.decode(String.self, forKey: .company)
        self.address1 = try container.decode(String.self, forKey: .address1)
        self.address2 = try container.decode(String.self, forKey: .address2)
        self.city = try container.decode(String.self, forKey: .city)
        self.state = try container.decode(String.self, forKey: .state)
        self.zip = try container.decode(String.self, forKey: .zip)
        self.country = try container.decode(String.self, forKey: .country)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.shippingAddress1 = try container.decode(String.self, forKey: .shippingAddress1)
        self.shippingAddress2 = try container.decode(String.self, forKey: .shippingAddress2)
        self.shippingCity = try container.decode(String.self, forKey: .shippingCity)
        self.shippingState = try container.decode(String.self, forKey: .shippingState)
        self.shippingZip = try container.decode(String.self, forKey: .shippingZip)
        self.shippingCountry = try container.decode(String.self, forKey: .shippingCountry)
        self.shippingPhoneNumber = try container.decode(String.self, forKey: .shippingPhoneNumber)
    }
}

public struct PaymentMethod: Codable, CustomStringConvertible {
    public var description: String {
        "PaymentMethod"
    }

    public let creditCard: CreditCard
    public let email: String
    public let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case creditCard = "credit_card"
        case email
        case metadata
    }

    public init(creditCard: CreditCard, email: String, metadata: [String: String]) {
        self.creditCard = creditCard
        self.email = email
        self.metadata = metadata
    }
}

public struct CreditCardResponse: Decodable {
    public let payment_method: PaymentMethod
}

public struct CreateCreditCardRequest: Encodable {
    public var paymentMethod: PaymentMethod

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
    }

    public init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }
}
