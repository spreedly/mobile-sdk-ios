public class CreditCardInfo {
    let fullName: String?
    let firstName: String?
    let lastName: String?
    var company: String?

    let number: SpreedlySecureOpaqueString
    let verificationValue: SpreedlySecureOpaqueString
    let year: Int
    let month: Int

    var primaryContact: Address?
    var shippingContact: Address?

    var retained: Bool?

    public convenience init(
            fullName: String,
            number: SpreedlySecureOpaqueString,
            verificationValue: SpreedlySecureOpaqueString,
            year: Int,
            month: Int
    ) {
        self.init(
                firstName: nil,
                lastName: nil,
                fullName: fullName,
                number: number,
                verificationValue: verificationValue,
                year: year,
                month: month
        )
    }

    public convenience init(
            firstName: String,
            lastName: String,
            number: SpreedlySecureOpaqueString,
            verificationValue: SpreedlySecureOpaqueString,
            year: Int,
            month: Int
    ) {
        self.init(
                firstName: firstName,
                lastName: lastName,
                fullName: nil,
                number: number,
                verificationValue: verificationValue,
                year: year,
                month: month
        )
    }

    private init(
            firstName: String?,
            lastName: String?,
            fullName: String?,
            number: SpreedlySecureOpaqueString,
            verificationValue: SpreedlySecureOpaqueString,
            year: Int,
            month: Int
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName

        self.number = number
        self.verificationValue = verificationValue
        self.year = year
        self.month = month
    }
}

public struct CreditCard: Codable {
    // Gateway-specific metadata
    public var token: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var data: [String: String]?
    public var storageState: String?
    public var test: Bool?
    public var metadata: [String: String]?
    public var callbackUrl: String?
    public var paymentMethodType: String?
    public var fingerprint: String?
    public var errors: [String]?

    // Card-specific data
    public var lastFourDigits: String?
    public var firstSixDigits: String?
    public var cardType: String?
    public var month: Int?
    public var year: Int?
    public var number: String?
    public var verificationValue: String?

    // Customer-specific data
    public var email: String?
    public var fullName: String?
    public var firstName: String?
    public var lastName: String?
    public var company: String?
    public var address1: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var zip: String?
    public var country: String?
    public var phoneNumber: String?
    public var shippingAddress1: String?
    public var shippingAddress2: String?
    public var shippingCity: String?
    public var shippingState: String?
    public var shippingZip: String?
    public var shippingCountry: String?
    public var shippingPhoneNumber: String?

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
        case fullName
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

    public init() {
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.token = try container.decode(String?.self, forKey: .token)
        self.createdAt = try container.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        // self.data
        self.storageState = try container.decode(String?.self, forKey: .storageState)
        self.test = try container.decode(Bool?.self, forKey: .test)
        // self.metadata
        self.callbackUrl = try container.decodeIfPresent(String.self, forKey: .callbackUrl)
        self.paymentMethodType = try container.decode(String?.self, forKey: .paymentMethodType)
        self.fingerprint = try container.decode(String?.self, forKey: .fingerprint)
        self.errors = try container.decode([String]?.self, forKey: .errors)

        self.lastFourDigits = try container.decode(String?.self, forKey: .lastFourDigits)
        self.firstSixDigits = try container.decode(String?.self, forKey: .firstSixDigits)
        self.cardType = try container.decode(String?.self, forKey: .cardType)
        self.month = try container.decode(Int?.self, forKey: .month)
        self.year = try container.decode(Int?.self, forKey: .month)
        self.number = try container.decode(String?.self, forKey: .number)
        self.verificationValue = try container.decode(String?.self, forKey: .verificationValue)

        self.email = try container.decode(String?.self, forKey: .email)
        self.fullName = try container.decode(String?.self, forKey: .fullName)
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

public struct CreatePaymentMethodRequest: Encodable {
    public var email: String?
    public var metadata: [String: String] = [:]
    public var creditCard: CreditCard?
    public var retained: Bool?

    public init(email: String, metadata: [String: String], creditCard: CreditCard, retained: Bool? = nil) {
        self.email = email
        self.metadata = metadata
        self.creditCard = creditCard
        self.retained = retained
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
    struct CodingData: Encodable {
        var paymentMethod: CreatePaymentMethodRequest
    }

    func wrapToData() throws -> Data {
        try Coders.encode(entity: CreatePaymentMethodRequest.CodingData(paymentMethod: self))
    }
}

public class Transaction<TPaymentMethod> where TPaymentMethod: PaymentMethodResultBase {
    public let token: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let succeeded: Bool
    public let transactionType: String?
    public let retained: Bool
    public let state: String?
    public let messageKey: String
    public let message: String
    public let paymentMethod: TPaymentMethod?
    public let errors: [SpreedlyError2]?

    init(from json: [String: Any]) {
        let errors = json.optObjectList("errors", { json in SpreedlyError2(from: json) })
        token = json["token"] as? String
        createdAt = json.optDate("created_at")
        updatedAt = json.optDate("created_at")
        succeeded = json["succeeded"] as? Bool ?? false
        transactionType = json["transaction_type"] as? String
        retained = json["retained"] as? Bool ?? false
        state = json["state"] as? String
        messageKey = json["messageKey"] as? String ?? errors?[0].key ?? "unknown"
        message = json["message"] as? String ?? errors?[0].message ?? "Unknown Error"
        paymentMethod = TPaymentMethod(from: json)
        self.errors = errors
    }
}

extension Transaction {

    static func unwrapFrom(data: Data) throws -> Transaction<TPaymentMethod> {
        let json = try Coders.decodeJson(data: data)
        if json.keys.contains("transation") {
            return Transaction(from: json.getObject("transaction"))
        } else {
            return Transaction(from: json)
        }
    }
}

struct CreateRecacheRequest: Encodable {
    let creditCard: CreditCard
}

extension CreateRecacheRequest {
    struct CodingData: Encodable {
        let paymentMethod: CreateRecacheRequest
    }

    func wrapToData() throws -> Data {
        try Coders.encode(entity: CreateRecacheRequest.CodingData(paymentMethod: self))
    }
}
