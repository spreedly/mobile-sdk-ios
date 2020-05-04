import Foundation

public struct SpreedlyError: Error, CustomStringConvertible {
    public var description: String {
        "SpreedlyError: \(message)"
    }

     public let message: String
}

public class Util {
    private let envKey: String, envSecret: String

    public init(envKey: String, envSecret: String) {
        self.envKey = envKey
        self.envSecret = envSecret
    }

    public static func decode<T>(data: Data) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }

    public static func encode<TEntity>(entity: TEntity) throws -> Data where TEntity: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        return try encoder.encode(entity)
    }

    func urlSession() -> URLSession {
        let config = URLSessionConfiguration.default
        let userPasswordString = "\(envKey):\(envSecret)"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let encodedCredentials = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        config.httpAdditionalHeaders = [
            "Authorization": "Basic \(encodedCredentials)",
            "Content-Type": "application/json"
        ]

        return URLSession(configuration: config)
    }
}
