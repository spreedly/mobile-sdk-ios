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

    public func retrieve<T>(_ urlString: String, completion: @escaping (T?, Error?) -> Void) throws where T: Decodable {
        guard let url = URL(string: urlString) else {
            throw SpreedlyError(message: "Unable to create url from \(urlString)")
        }

        let session = urlSession()
        session.dataTask(with: url) { data, res, err in
            guard err == nil else {
                print("Error retrieving url \(urlString)", err as Any)
                completion(nil, err)
                return
            }

            guard let data = data else {
                print("Expected data but was nil from url \(urlString)", res as Any)
                return
            }
            print("Got response: ", String(data: data, encoding: .utf8)!)

            let entity: T
            do {
                entity = try Util.decode(data: data)
            } catch {
                print("error occurred while decoding \(error)")
                completion(nil, error)
                return
            }
            completion(entity, nil)
        }.resume()
    }

    public func create<TRequest, TResponse>(
            _ urlString: String,
            entity: TRequest,
            completion: @escaping (TResponse?, Error?) -> Void
    ) throws where TRequest: Encodable, TResponse: Decodable {
        guard let url = URL(string: urlString) else {
            throw SpreedlyError(message: "Unable to create url from \(urlString)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let encodedData = try Util.encode(entity: entity)
            request.httpBody = encodedData
            let jsonString = String(data: encodedData, encoding: .utf8)!
            print("Request is")
            print(jsonString)
        } catch {
            completion(nil, error)
            return
        }

        let session = urlSession()
        session.dataTask(with: request) { data, res, err in
            guard err == nil else {
                print("Error retrieving url \(urlString)", err as Any)
                completion(nil, err)
                return
            }
            guard let data = data else {
                print("Expected data but was nil from url \(urlString)", res as Any)
                return
            }

            print("Response was ")
            let jsonString = String(data: data, encoding: .utf8)!
            print(jsonString)

            let response: TResponse
            do {
                response = try Util.decode(data: data)
            } catch {
                print("error occurred while decoding \(error)")
                completion(nil, error)
                return
            }
            completion(response, nil)
        }.resume()

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
