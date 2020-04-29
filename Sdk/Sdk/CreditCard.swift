public struct CreditCard: Codable, CustomStringConvertible {
    // Gateway-specific metadata
    public var token: String? = nil
    public var createdAt: Date? = nil
    public var updatedAt: Date? = nil
    public var data: [String: String]? = nil
    public var storageState: String? = nil
    public var test: Bool? = nil
    public var metadata: [String: String]? = nil
    public var callbackUrl: String? = nil
    public var paymentMethodType: String? = nil
    public var fingerprint: String? = nil
    public var errors: [String]? = nil

    // Card-specific data
    public var lastFourDigits: String? = nil
    public var firstSixDigits: String? = nil
    public var cardType: String? = nil
    public var month: String? = nil
    public var year: String? = nil
    public var number: String? = nil
    public var verificationValue: String? = nil

    // Customer-specific data
    public var email: String? = nil
    public var firstName: String? = nil
    public var lastName: String? = nil
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

    enum CodingKeys: CodingKey {
        case token
        case createdAt
        case updatedAt
        case data
        case storageState
        case test
        case metadata
        case callbackUrl
        case paymentMethodType
        case fingerprint
        case errors

        case lastFourDigits
        case firstSixDigits
        case number
        case month
        case year
        case cardType
        case verificationValue

        case email
        case firstName
        case lastName
        case company
        case address1
        case address2
        case city
        case state
        case zip
        case country
        case phoneNumber
        case shippingAddress1
        case shippingAddress2
        case shippingCity
        case shippingState
        case shippingZip
        case shippingCountry
        case shippingPhoneNumber
    }

    public var description: String {
        "CreditCard(\(self.number ?? "????"))"
    }

    public init() { }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.token = try container.decode(String?.self, forKey: .token)
        self.createdAt = try container.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        // self.data
        self.storageState = try container.decode(String?.self, forKey: .storageState)
        self.test = try container.decode(Bool?.self, forKey: .test)
        // self.metadata
        self.callbackUrl = try container.decode(String?.self, forKey: .callbackUrl)
        self.paymentMethodType = try container.decode(String?.self, forKey: .paymentMethodType)
        self.fingerprint = try container.decode(String?.self, forKey: .fingerprint)
        self.errors = try container.decode([String]?.self, forKey: .errors)


        self.lastFourDigits = try container.decode(String?.self, forKey: .lastFourDigits)
        self.firstSixDigits = try container.decode(String?.self, forKey: .firstSixDigits)
        self.cardType = try container.decode(String?.self, forKey: .cardType)
        let intMonth = try! container.decode(Int?.self, forKey: .month)
        self.month = String(intMonth!)
        let intYear = try! container.decode(Int?.self, forKey: .year)
        self.year = String(intYear!)
        self.number = try container.decode(String?.self, forKey: .number)
        self.verificationValue = try container.decode(String?.self, forKey: .verificationValue)

        self.email = try container.decode(String?.self, forKey: .email)
        self.firstName = try container.decode(String?.self, forKey: .firstName)
        self.lastName = try container.decode(String?.self, forKey: .lastName)
        self.company = try container.decode(String?.self, forKey: .company)
        self.address1 = try container.decode(String?.self, forKey: .address1)
        self.address2 = try container.decode(String?.self, forKey: .address2)
        self.city = try container.decode(String?.self, forKey: .city)
        self.state = try container.decode(String?.self, forKey: .state)
        self.zip = try container.decode(String?.self, forKey: .zip)
        self.country = try container.decode(String?.self, forKey: .country)
        self.phoneNumber = try container.decode(String?.self, forKey: .phoneNumber)
        self.shippingAddress1 = try container.decode(String?.self, forKey: .shippingAddress1)
        self.shippingAddress2 = try container.decode(String?.self, forKey: .shippingAddress2)
        self.shippingCity = try container.decode(String?.self, forKey: .shippingCity)
        self.shippingState = try container.decode(String?.self, forKey: .shippingState)
        self.shippingZip = try container.decode(String?.self, forKey: .shippingZip)
        self.shippingCountry = try container.decode(String?.self, forKey: .shippingCountry)
        self.shippingPhoneNumber = try container.decode(String?.self, forKey: .shippingPhoneNumber)
    }
}

extension CreditCard {
    public struct CodingData: Decodable {
        var paymentMethod: CreditCard

        public init(paymentMethod: CreditCard) {
            self.paymentMethod = paymentMethod
        }
    }
}

public struct CreatePaymentMethodRequest: Encodable, CustomStringConvertible {
    public var description: String {
        "CustomPaymentMethodRequest"
    }

    public var email: String? = nil
    public var metadata: [String: String] = [:]
    public var creditCard: CreditCard? = nil

    public init(email: String, metadata: [String:String], creditCard: CreditCard) {
        self.email = email
        self.metadata = metadata
        self.creditCard = creditCard
    }
}

extension CreatePaymentMethodRequest {
    /*
        When creating a payment method, the API expects an object with a single key, "payment_method".

        Example:
        {
            "payment_method": {
                "email": "...",
                "metadata: {...},
                "credit_card: {...}
            }
        }

        The CodingData struct represents that the outermost object with the single "payment_method" key in it.
    */
    public struct CodingData: Encodable {
        var paymentMethod: CreatePaymentMethodRequest

        public init(paymentMethod: CreatePaymentMethodRequest) {
            self.paymentMethod = paymentMethod
        }
    }
}

public struct Transaction: Decodable {
    public let token: String
    public let createdAt: Date
    public let updatedAt: Date
    public let succeeded: Bool
    public let transactionType: String
    public let retained: Bool
    public let state: String
    public let messageKey: String
    public let message: String
    public let paymentMethod: CreditCard
}

extension Transaction {
    public struct CodingData: Decodable {
        var transaction: Transaction

        public init(transaction: Transaction) {
            self.transaction = transaction
        }
    }
}
