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

print("Hello, World!")

let BASE_URL = "https://core.spreedly.com"

func urlSession() -> URLSession {
    let config = URLSessionConfiguration.default
    let envKey = ENV_KEY! // TODO: replace me with an injected value
    let secret = ENV_SECRET!
    let userPasswordString = "\(envKey):\(secret)"
    let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
    let encodedCredentials = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    config.httpAdditionalHeaders = ["Authorization": "Basic \(encodedCredentials)"]
    return URLSession(configuration: config)
}

func getJson<T>(url urlString: String, completion: @escaping (T) -> ()) throws where T: Decodable {
    guard let url = URL(string: BASE_URL + urlString) else {
        throw NSError(domain: "URLError", code: -1)
    }

    URLSession.shared.dataTask(with: url) { data, res, err in
        let session = urlSession()
        session.dataTask(with: url) { data, res, err in
            guard err == nil else {
                print("Error retrieving url \(urlString)", err)
                return
            }
            guard let data = data else {
                print("Expected data but was nil from url \(urlString)" , res)
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let gw = try decoder.decode(T.self, from: data)
                completion(gw)
            } catch {
                print("Decoding error \(error)")
            }
        }
    }.resume()

}


//func getJson(completion: @escaping (Response) -> ()) {
//    let urlString = "/v1/payment_methods.json"
//    if let url = URL(string: urlString) {
//        URLSession.shared.dataTask(with: url) { data, res, err in
//            if let data = data {
//                print ("hey")
//
//                let decoder = JSONDecoder()
//                if let json = try? decoder.decode(Response.self, from: data) {
//                    completion(json)
//                }
//            }
//        }.resume()
//    }
//}

public class Gateway: Decodable, CustomStringConvertible {
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

public struct SpreedlyError: Error {
     public let message: String
}


func getGateway(completion: @escaping (GatewayResponse) -> ()) throws {
    let urlString = BASE_URL + "/v1/gateways.json"

    guard let url = URL(string: urlString) else {
        throw SpreedlyError(message: "Unable to create url from \(urlString)")
    }

//    do {
//        try getJson(url: urlString, completion: completion)
//    } catch {
//        print("Got an error", error)
//    }

//    if let url = URL(string: "https://core.spreedly.com/\(urlString)") {
//        let config = URLSessionConfiguration.default
//        let envKey = "A54wvT9knP8Sc6ati68epUcq72l"
//        let secret = "0f0Cpq17bb5mAAUxtx0QmY2mXyHnEk26uYTrPttn4PIMKZC4zdTJVJSk4YHbe1Ij"
//        let userPasswordString = "\(envKey):\(secret)"
//        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
//        let encodedCredentials = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
//        let authString = "Basic \(encodedCredentials)"
//        config.httpAdditionalHeaders = ["Authorization": authString]
//        let session = URLSession(configuration: config)
        let session = urlSession()
        session.dataTask(with: url) { data, res, err in
            guard err == nil else {
                print("Error retrieving url \(urlString)", err)
                return
            }

            guard let data = data else {
                print("Expected data but was nil from url \(urlString)" , res)
                return
            }

//            if let data = data {

                print("hey")

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let gw = try decoder.decode(GatewayResponse.self, from: data)
                    completion(gw)
                } catch {
                    print("error occurred \(error)")
                }
//                decoder.decode(GatewayResponse.self, from: data)

//                if let json = try? decoder.decode(GatewayResponse.self, from: data) {
//                    completion(json)
//                } else {
//                    print("something bad happened in decoding: \(error)")
//                }

//            } else {
//                print("something bad happened in data")
//            }
        }.resume()

}

func onGatewayComplete(response: GatewayResponse) {
    print(response)
}

let ENV_KEY = ProcessInfo.processInfo.environment["ENV_KEY"]
let ENV_SECRET = ProcessInfo.processInfo.environment["ENV_SECRET"]

print("Getting gateway")
try getGateway(completion: onGatewayComplete)
print("Done requesting gateway")

CFRunLoopRun()

//var shouldKeepRunning = true
//
//let theRL = RunLoop.current
//while shouldKeepRunning && theRL.run(mode: RunLoop.Mode.default, before: Date.distantFuture()) { }
