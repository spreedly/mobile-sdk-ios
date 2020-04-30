//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation

@objc class SpreedlySecureOpaqueStringImpl: NSObject, SpreedlySecureOpaqueString {
    private var data: [Character] = [];

    override internal init() {
        super.init();
    }

    convenience internal init(from source: String) {
        self.init();
        append(string: source);
    }

    func clear() {
        data = []
    }

    func append(string s: String) {
        for c in s {
            data.append(c)
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