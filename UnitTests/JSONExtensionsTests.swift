//
// Created by Eli Thompson on 5/8/20.
//

import Foundation
import XCTest
@testable import CoreSdk

class DecodeJsonTests: XCTestCase {
    func testDecodeJsonWhenNotJsonShouldThrow() {
        let notJson = "<ul><li>list item</li></ul>"
        let data = notJson.data(using: .utf8)!
        XCTAssertThrowsError(try data.decodeJson()) { error in
            XCTAssertEqual(error as? JSONError, .expectedObject)
        }
    }

    func testDecodeWhenNotJsonObjectShouldThrow() {
        let validJson = """
                        "I'm just a string"
                        """
        let data = validJson.data(using: .utf8)!
        XCTAssertThrowsError(try data.decodeJson()) { error in
            XCTAssertEqual(error as? JSONError, .expectedObject)
        }
    }

    func testDecodeWhenValidJsonObjectShouldDecode() throws {
        let validJson = """
                        {"key": "value"}
                        """
        let data = validJson.data(using: .utf8)!
        let decodedObject = try data.decodeJson()
        XCTAssertEqual("value", try decodedObject.string(for: "key"))
    }
}

let json = try! """
                {
                    "object": {"key": "value"},
                    "list": [
                        {"type": "Int"},
                        {"type": "String"}
                    ],
                    "intList": [1, 2, 3],
                    "date": "2012-05-06T22:35:12-07:00",
                    "string": "stringValue",
                    "bool": true,
                    "stringBoolTrue": "true",
                    "stringBoolFalse": "false",
                    "int": 42,
                    "stringInt": "9001"
                }
                """.data(using: .utf8)!.decodeJson()

class ObjectTests: XCTestCase {
    func testWhenMissingShouldThrow() {
        XCTAssertThrowsError(try json.object(for: "missing")) { error in
            XCTAssertEqual(error as? JSONError, JSONError.keyNotFound(key: "missing"))
        }
    }

    func testWhenFoundShouldReturn() throws {
        let foundObject = try json.object(for: "object")
        XCTAssertEqual("value", try foundObject.string(for: "key"))
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.object(optional: "missing"))
    }

    func testOptionalWhenFoundShouldReturn() {
        let foundObject = json.object(optional: "object")
        XCTAssertEqual("value", try foundObject!.string(for: "key"))
    }
}

class ObjectListTests: XCTestCase {
    func testWhenMissingShouldThrow() {
        XCTAssertThrowsError(try json.objectList(for: "missing", { _ in false })) { error in
            XCTAssertEqual(error as? JSONError, JSONError.keyNotFound(key: "missing"))
        }
    }

    func testWhenFoundShouldReturn() throws {
        let foundList = try json.objectList(for: "list") { inner in
            try inner.string(for: "type")
        }
        XCTAssertEqual(["Int", "String"], foundList)
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.objectList(optional: "missing", { _ in false }))
    }

    func testOptionalWhenFoundShouldReturn() {
        let foundList = json.objectList(optional: "list") { inner in
            try inner.string(for: "type")
        }
        XCTAssertEqual(["Int", "String"], foundList)
    }

    func testWhenElementIsNotObjectShouldReturnNil() {
        XCTAssertNil(json.objectList(optional: "intList", { $0 }))
    }
}

class DateTests: XCTestCase {
    let specialDay = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.init(abbreviation: "PDT"),
            year: 2012, month: 5, day: 6, hour: 22, minute: 35, second: 12).date

    func testWhenMissingShouldThrow() {
        XCTAssertThrowsError(try json.date(for: "missing")) { error in
            XCTAssertEqual(error as? JSONError, JSONError.keyNotFound(key: "missing"))
        }
    }

    func testWhenFoundShouldReturn() throws {
        let found = try json.date(for: "date")
        XCTAssertEqual(specialDay, found)
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.date(optional: "missing"))
    }

    func testOptionalWhenFoundShouldReturn() {
        let found = json.date(optional: "date")
        XCTAssertEqual(specialDay, found)
    }
}

class StringTests: XCTestCase {
    func testWhenMissingShouldThrow() {
        XCTAssertThrowsError(try json.string(for: "missing")) { error in
            XCTAssertEqual(error as? JSONError, JSONError.keyNotFound(key: "missing"))
        }
    }

    func testWhenFoundShouldReturn() throws {
        let found = try json.string(for: "string")
        XCTAssertEqual("stringValue", found)
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.string(optional: "missing"))
    }

    func testOptionalWhenFoundShouldReturn() {
        let found = json.string(optional: "string")
        XCTAssertEqual("stringValue", found)
    }
}

class BoolTests: XCTestCase {
    func testWhenMissingShouldThrow() {
        XCTAssertThrowsError(try json.bool(for: "missing")) { error in
            XCTAssertEqual(error as? JSONError, JSONError.keyNotFound(key: "missing"))
        }
    }

    func testWhenFoundShouldReturn() throws {
        let found = try json.bool(for: "bool")
        XCTAssertEqual(true, found)
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.bool(optional: "missing"))
    }

    func testOptionalWhenFoundShouldReturn() {
        let found = json.bool(optional: "bool")
        XCTAssertEqual(true, found)
    }

    func testWhenStringValuedShouldReturnValue() {
        XCTAssertEqual(true, json.bool(optional: "stringBoolTrue"), "true string")
        XCTAssertEqual(false, json.bool(optional: "stringBoolFalse"), "false string")
        XCTAssertNil(json.bool(optional: "object"), "non-bool non-string")
        XCTAssertNil(json.bool(optional: "string"), "non-bool string")
    }
}

class IntTests: XCTestCase {
    func testWhenMissingShouldThrow() {
        XCTAssertThrowsError(try json.int(for: "missing")) { error in
            XCTAssertEqual(error as? JSONError, JSONError.keyNotFound(key: "missing"))
        }
    }

    func testWhenFoundShouldReturn() throws {
        let found = try json.int(for: "int")
        XCTAssertEqual(42, found)
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.int(optional: "missing"))
    }

    func testOptionalWhenFoundShouldReturn() {
        let found = json.int(optional: "int")
        XCTAssertEqual(42, found)
    }

    func testWhenStringValuedShouldReturnValue() {
        XCTAssertEqual(9001, json.int(optional: "stringInt"), "as string")
        XCTAssertNil(json.int(optional: "string"), "non-int")
    }
}

class EnumValueTests: XCTestCase {
    enum StubEnum: String {
        case stringValue
    }

    func testOptionalWhenMissingShouldReturnNil() {
        XCTAssertNil(json.enumValue(optional: "missing") as StubEnum?)
    }

    func testOptionalWhenFoundShouldReturn() {
        let found: StubEnum? = json.enumValue(optional: "string")
        XCTAssertEqual(found, StubEnum.stringValue)
    }
}
