//
// Created by Eli Thompson on 5/4/20.
//

import Foundation

enum JSONError: Error, Equatable {
    case keyNotFound(key: String)
    case expectedObject
}

extension Data {
    func decodeJson() throws -> [String: Any] {
        guard let json = try? JSONSerialization.jsonObject(with: self) as? [String: Any] else {
            throw JSONError.expectedObject
        }
        return json
    }
}

extension Dictionary where Key == String, Value == Any {

    func encodeJson() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }

    func object(for key: String) throws -> [String: Any] {
        guard let result = object(optional: key) else {
            throw JSONError.keyNotFound(key: key)
        }
        return result
    }

    func object(optional key: String) -> [String: Any]? {
        self[key] as? [String: Any]
    }

    func objectList<R>(for key: String, _ closure: (_ json: [String: Any]) throws -> R) throws -> [R] {
        guard let result: [R] = objectList(optional: key, closure) else {
            throw JSONError.keyNotFound(key: key)
        }
        return result
    }

    func objectList<R>(optional key: String, _ closure: (_ json: [String: Any]) throws -> R) -> [R]? {
        try? (self[key] as? [Any])?.map {
            guard let child = $0 as? [String: Any] else {
                throw JSONError.expectedObject
            }
            return try closure(child)
        }
    }

    func date(for key: String) throws -> Date {
        guard let result = date(optional: key) else {
            throw JSONError.keyNotFound(key: key)
        }
        return result
    }

    func date(optional key: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        guard let value = string(optional: key),
              let date = dateFormatter.date(from: value) else {
            return nil
        }
        return date
    }

    func string(for key: String) throws -> String {
        guard let result = string(optional: key) else {
            throw JSONError.keyNotFound(key: key)
        }
        return result
    }

    func string(optional key: String) -> String? {
        self[key] as? String
    }

    func bool(for key: String) throws -> Bool {
        guard let result = bool(optional: key) else {
            throw JSONError.keyNotFound(key: key)
        }
        return result

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
        guard let result = int(optional: key) else {
            throw JSONError.keyNotFound(key: key)
        }
        return result
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

    func enumValue<T: RawRepresentable>(optional key: String) -> T? where T.RawValue == String {
        guard let value = self[key] as? String else {
            return nil
        }
        return T(rawValue: value)
    }
}

extension Dictionary where Key == String, Value == Any {
    mutating func maybeSet<T>(_ key: String, _ value: T?) {
        if let value = value {
            self[key] = value
        }
    }

    mutating func setOpaqueString(_ key: String, _ value: SpreedlySecureOpaqueString?) throws {
        guard let unwrappedValue = value else {
            return
        }
        guard let value = unwrappedValue as? SpreedlySecureOpaqueStringImpl else {
            throw SpreedlySecurityError.invalidOpaqueString
        }
        self[key] = value.internalToString()
    }
}
