public struct CreditCard: Codable, CustomStringConvertible {
    // Gateway-specific metadata
    public var token: String? = nil
    public var createdAt: Date? = nil
    public var updatedAt: Date? = nil
    public var storageState: String? = nil
    public var test: Bool? = nil
    public var metadata: [String: String]? = nil
    public var paymentMethodType: String? = nil
    public var fingerprint: String? = nil

    // Card-specific data
    public var number: String = ""
    public var verificationValue: String = ""
    public var month: String = ""
    public var year: String = ""
    public var cardType: String? = nil

    // Customer-specific data
    public var email: String? = nil
    public var firstName: String = ""
    public var lastName: String = ""
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
        case token
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case storageState = "storage_state"
        case test
        case metadata
        case paymentMethodType = "payment_method_type"
        case fingerprint

        case number
        case verificationValue = "verification_value"
        case month
        case year
        case cardType = "card_type"

        case email
        case firstName = "first_name"
        case lastName = "last_name"
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
    public let paymentMethod: PaymentMethod

    enum CodingKeys: String, CodingKey {
        case token
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case succeeded
        case transactionType = "transaction_type"
        case retained
        case state
        case messageKey = "message_key"
        case message
        case paymentMethod = "payment_method"
    }
}

public struct CreditCardResponse: Decodable {
    public let transaction: Transaction
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

enum PaymentMethodResponse {
    case creditCard(CreditCardPaymentMethodResponse)
    case thirdPartyToken(Int)
}

public class PaymentMethodResponseBase: Decodable {
    public var token: String
    public var createdAt: Date
    public var updatedAt: Date
    public var email: String?
    public var data: [String:Decodable]?
    public var storageState: String
    public var test: Bool
    public var metadata: [String:Decodable]?
    public var callbackUrl: String?
    public var paymentMethodType: String
    public var errors: [String]?

    enum CodingKeys: String, CodingKey {
        case token
        case createdAt
        case updatedAt
        case email
        case data
        case storageState
        case test
        case metadata
        case callbackUrl
        case paymentMethodType
        case errors
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: CodingKeys.token)
        createdAt = try container.decode(Date.self, forKey: CodingKeys.createdAt)
        updatedAt = try container.decode(Date.self, forKey: CodingKeys.updatedAt)
        email = try container.decode(String.self, forKey: CodingKeys.email)
//        self.data = try container.decode([String:Decodable]?.self, forKey: CodingKeys.data)
        data = Dictionary<String, Decodable>()
        storageState = try container.decode(String.self, forKey: CodingKeys.storageState)
        test = try container.decode(Bool.self, forKey: CodingKeys.test)
//        self.metadata = try container.decode([String:Decodable]?.self, forKey: CodingKeys.metadata)
        metadata = Dictionary<String, Decodable>()
        callbackUrl = try container.decodeIfPresent(String.self, forKey: CodingKeys.callbackUrl)
        paymentMethodType = try container.decode(String.self, forKey: CodingKeys.paymentMethodType)
        errors = try container.decode([String]?.self, forKey: CodingKeys.errors)
    }
}

public class CreditCardPaymentMethodResponse: PaymentMethodResponseBase {
    public var lastFourDigits: String
    public var firstSixDigits: String
    public var cardType: String
    public var firstName: String
    public var lastName: String
    public var address1: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var zip: String?
    public var country: String?
    public var phoneNumber: String?
    public var company: String?
    public var fullName: String?
    public var eligibleForCardUpdater: Bool
    public var shippingAddress1: String?
    public var shippingAddress2: String?
    public var shippingCity: String?
    public var shippingState: String?
    public var shippingZip: String?
    public var shippingCountry: String?
    public var shippingPhoneNumber: String?
    public var fingerprint: String
    public var number: String
    public var verificationValue: String

    enum CodingKeys: String, CodingKey {
        case lastFourDigits
        case firstSixDigits
        case cardType
        case firstName
        case lastName
        case address1
        case address2
        case city
        case state
        case zip
        case country
        case phoneNumber
        case company
        case fullName
        case eligibleForCardUpdater
        case shippingAddress1
        case shippingAddress2
        case shippingCity
        case shippingState
        case shippingZip
        case shippingCountry
        case shippingPhoneNumber
        case fingerprint
        case number
        case verificationValue
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastFourDigits = try container.decode(String.self, forKey: CodingKeys.lastFourDigits)
        firstSixDigits = try container.decode(String.self, forKey: CodingKeys.firstSixDigits)
        cardType = try container.decode(String.self, forKey: CodingKeys.cardType)
        firstName = try container.decode(String.self, forKey: CodingKeys.firstName)
        lastName = try container.decode(String.self, forKey: CodingKeys.lastName)
        address1 = try container.decode(String?.self, forKey: CodingKeys.address1)
        address2 = try container.decode(String?.self, forKey: CodingKeys.address2)
        city = try container.decode(String?.self, forKey: CodingKeys.city)
        state = try container.decode(String?.self, forKey: CodingKeys.state)
        zip = try container.decode(String?.self, forKey: CodingKeys.zip)
        country = try container.decode(String?.self, forKey: CodingKeys.country)
        phoneNumber = try container.decode(String?.self, forKey: CodingKeys.phoneNumber)
        fullName = try container.decode(String?.self, forKey: CodingKeys.fullName)
        eligibleForCardUpdater = try container.decode(Bool.self, forKey: CodingKeys.eligibleForCardUpdater)
        shippingAddress1 = try container.decode(String?.self, forKey: CodingKeys.shippingAddress1)
        shippingAddress2 = try container.decode(String?.self, forKey: CodingKeys.shippingAddress2)
        shippingCity = try container.decode(String?.self, forKey: CodingKeys.shippingCity)
        shippingState = try container.decode(String?.self, forKey: CodingKeys.shippingState)
        shippingZip = try container.decode(String?.self, forKey: CodingKeys.shippingZip)
        shippingCountry = try container.decode(String?.self, forKey: CodingKeys.shippingCountry)
        shippingPhoneNumber = try container.decode(String?.self, forKey: CodingKeys.shippingPhoneNumber)
        fingerprint = try container.decode(String.self, forKey: CodingKeys.fingerprint)
        number = try container.decode(String.self, forKey: CodingKeys.number)
        verificationValue = try container.decode(String.self, forKey: CodingKeys.verificationValue)
        try super.init(from: decoder)
    }
}

public struct ShowCreditCardResponse: Decodable {
    public var paymentMethod: CreditCardPaymentMethodResponse
}
