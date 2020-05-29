//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

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
