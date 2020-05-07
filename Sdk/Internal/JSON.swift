//
// Created by Eli Thompson on 5/4/20.
//

import Foundation

/**
 Decode and encode functions with common settings.
*/
struct Coders {

    @available(*, deprecated, message: "use Data.decodeJson()")
    static func decode<T>(data: Data) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }

    @available(*, deprecated, message: "use [String:Any].encodeJson()")
    static func encode<TEntity>(entity: TEntity) throws -> Data where TEntity: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        return try encoder.encode(entity)
    }
}

enum JSONError: Error {
    case keyNotFound(key: String)
    case expectedObject
}

extension Data {
    func decodeJson() throws -> [String: Any] {
        if let json = try JSONSerialization.jsonObject(with: self) as? [String: Any] {
            return json
        } else {
            throw JSONError.expectedObject
        }
    }
}

extension Dictionary where Key == String, Value == Any {

    func encodeJson() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }

    func object(for key: String) throws -> [String: Any] {
        if let result = object(optional: key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func object(optional key: String) -> [String: Any]? {
        self[key] as? [String: Any]
    }

    func objectList<R>(for key: String, _ closure: (_ json: [String: Any]) throws -> R) throws -> [R] {
        if let result: [R] = objectList(optional: key, closure) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func objectList<R>(optional key: String, _ closure: (_ json: [String: Any]) throws -> R) -> [R]? {
        try? (self[key] as? [Any])?.map {
            if let child = $0 as? [String: Any] {
                return try closure(child)
            } else {
                throw JSONError.expectedObject
            }
        }
    }

    func date(for key: String) throws -> Date {
        if let result = date(optional: key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func date(optional key: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        if let value = string(optional: key),
           let date = dateFormatter.date(from: value) {
            return date
        } else {
            return nil
        }
    }

    func string(for key: String) throws -> String {
        if let result = string(optional: key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func string(optional key: String) -> String? {
        self[key] as? String
    }

    func bool(for key: String) throws -> Bool {
        if let result = bool(optional: key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func bool(optional key: String) -> Bool? {
        if let result = self[key] as? Bool {
            return result
        } else if let result = self[key] as? String {
            if result == "true" {
                return true
            } else if result == "false" {
                return false
            }
        }
        return nil
    }

    func int(for key: String) throws -> Int {
        if let result = int(optional: key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func int(optional key: String) -> Int? {
        if let result = self[key] as? Int {
            return result
        } else if let result = self[key] as? String,
                  let number = Int(result) {
            return number
        }
        return nil
    }
}

extension Dictionary where Key == String, Value == Any {
    mutating func maybeSetEnum<T: RawRepresentable>(_ key: String, _ value: T?) where T.RawValue == String {
        if let value = value {
            self[key] = value.rawValue
        }
    }

    mutating func maybeSet<T>(_ key: String, _ value: T?) {
        if let value = value {
            self[key] = value
        }
    }

    mutating func setOpaqueString(_ key: String, _ value: SpreedlySecureOpaqueString) throws {
        if let value = value as? SpreedlySecureOpaqueStringImpl {
            self[key] = value.internalToString()
        } else {
            throw SpreedlySecurityError.invalidOpaqueString
        }
    }
}
