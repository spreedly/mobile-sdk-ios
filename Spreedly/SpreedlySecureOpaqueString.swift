//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

/// A representation of a String where the content of that String is intentionally obscured both reminding the
/// developer that it should be carefully handled and to limit the possibility of it being recorded in logs, dumps,
/// or prints.
@objc(SPRSecureOpaqueString)
public protocol SpreedlySecureOpaqueString {
    /// Clears the content.
    func clear()

    /// Appends the given String to the content.
    func append(_ string: String)

    /// Removes the last character from the content.
    func removeLastCharacter()
}

class SpreedlySecureOpaqueStringImpl: NSObject, SpreedlySecureOpaqueString {
    private var data: [Character] = []

    override internal init() {
        super.init()
    }

    convenience internal init(from source: String) {
        self.init()
        append(source)
    }

    func clear() {
        data = []
    }

    func append(_ string: String) {
        for char in string {
            data.append(char)
        }
    }

    func removeLastCharacter() {
        data.removeLast()
    }

    internal func internalToString() -> String {
        String(data)
    }
}

extension SpreedlySecureOpaqueStringImpl: Encodable {
    func encode(to encoder: Encoder) throws {
        var container: SingleValueEncodingContainer = encoder.singleValueContainer()
        try container.encode(internalToString())
    }
}

@objc(SPRSecureOpaqueStringBuilder)
public class SpreedlySecureOpaqueStringBuilder: NSObject {
    /// Builds an instance of `SpreedlySecureOpaqueString` from the given string.
    /// Returns nil if the given string was nil.
    @objc public static func build(from string: String?) -> SpreedlySecureOpaqueString {
        guard let string = string else {
            return SpreedlySecureOpaqueStringImpl()
        }

        return SpreedlySecureOpaqueStringImpl(from: string)
    }
}
