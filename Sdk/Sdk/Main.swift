//
//  main.swift
//  hello_cli
//
//  Created by Eli Thompson on 4/14/20.
//  Copyright © 2020 Eli Thompson. All rights reserved.
//

import Foundation

public struct CreditCard {
    public let firstName: String
    public let lastName: String
}

public struct PaymentMethod {
    public let creditCard: CreditCard
}

public struct Response : Decodable {
    public let paymentMethod: PaymentMethod
    public let email: String
    public let metadata: Dictionary<String, Any>

    public init(from decoder: Decoder) throws {
        let cc = CreditCard(firstName: "Card", lastName: "Holder")
        paymentMethod = PaymentMethod(creditCard: cc)
        email = "some@email.com"
        metadata = [
            "key": "some key",
            "another_key": 123,
            "final_key": true
        ]
    }
}

public class Gateway: Decodable, CustomStringConvertible {
    public static let endpoint = "/v1/gateways.json"

    public var description: String {
        "Gateway(name: \(name))"
    }

    public let token: String
    public let gateway_type: String
    public let state: String
    public let name: String
    public let created_at: Date
}

public class GatewayResponse: Decodable, CustomStringConvertible {
    public let gateways: [Gateway]

    public var description: String {
        "GatewayResponse(gateways: \(gateways))"
    }
}

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

    public func retrieve<T>(_ urlString: String, completion: @escaping (T?, Error?) -> ()) throws where T: Decodable{
        guard let url = URL(string: urlString) else {
            throw SpreedlyError(message: "Unable to create url from \(urlString)")
        }

        let session = urlSession()
        session.dataTask(with: url) { data, res, err in
            guard err == nil else {
                print("Error retrieving url \(urlString)", err)
                completion(nil, err)
                return
            }

            guard let data = data else {
                print("Expected data but was nil from url \(urlString)" , res)
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let gw: T
            do {
                gw = try decoder.decode(T.self, from: data)
            } catch {
                print("error occurred while decoding \(error)")
                completion(nil, error)
                return
            }
            completion(gw, nil)
        }.resume()
    }

    func urlSession() -> URLSession {
        let config = URLSessionConfiguration.default
        let userPasswordString = "\(envKey):\(envSecret)"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let encodedCredentials = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        config.httpAdditionalHeaders = ["Authorization": "Basic \(encodedCredentials)"]
        return URLSession(configuration: config)
    }
}




//var shouldKeepRunning = true
//
//let theRL = RunLoop.current
//while shouldKeepRunning && theRL.run(mode: RunLoop.Mode.default, before: Date.distantFuture()) { }
