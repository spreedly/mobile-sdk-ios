//
// Created by Eli Thompson on 5/4/20.
//

import Foundation

/**
 Decode and encode functions with common settings.
*/
struct Coders {
    static func decodeJson(data: Data) throws -> [String: Any] {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json
        } else {
            throw JSONError.expectedObject
        }
    }

    static func decode<T>(data: Data) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }

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

extension Dictionary where Key == String, Value == Any {

    func getObject(_ key: String) throws -> [String: Any] {
        if let result = optObject(key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func optObject(_ key: String) -> [String: Any]? {
        self[key] as? [String: Any]
    }

    func getObjectList<R>(_ key: String, _ closure: (_ json: [String: Any]) throws -> R) throws -> [R] {
        if let result: [R] = optObjectList(key, closure) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func optObjectList<R>(_ key: String, _ closure: (_ json: [String: Any]) throws -> R) -> [R]? {
        try? (self[key] as? [Any])?.map {
            if let child = $0 as? [String: Any] {
                return try closure(child)
            } else {
                throw JSONError.expectedObject
            }
        }
    }

    func getDate(_ key: String) throws -> Date {
        if let result = optDate(key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func optDate(_ key: String) -> Date? {
        nil
    }

    func getString(_ key: String) throws -> String {
        if let result = optString(key) {
            return result
        } else {
            throw JSONError.keyNotFound(key: key)
        }
    }

    func optString(_ key: String) -> String? {
        self[key] as? String
    }
}

extension Dictionary where Key == String, Value == Any {
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
