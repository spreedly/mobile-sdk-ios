//
// Created by Eli Thompson on 5/4/20.
//

import Foundation

/**
 Decode and encode functions with common settings.
*/
struct Coders {
    static func decodeJson(data: Data) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: data) as! [String: Any]
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

extension Dictionary where Key == String, Value == Any {

    func getObject(_ key: String) -> [String: Any] {
        self[key] as! [String: Any]
    }

    func optObject(_ key: String) -> [String: Any]? {
        self[key] as? [String: Any]
    }

    func getObjectList<R>(_ key: String, _ closuer: (_ json: [String: Any]) -> R) -> [R] {
        (self[key] as! [Any]).map {
            closuer($0 as! [String: Any])
        }
    }

    func optObjectList<R>(_ key: String, _ closuer: (_ json: [String: Any]) -> R) -> [R]? {
        (self[key] as? [Any])?.map {
            closuer($0 as! [String: Any])
        }
    }

    func getDate(_ key: String) -> Date {
        Date()
    }

    func optDate(_ key: String) -> Date? {
        nil
    }
}
