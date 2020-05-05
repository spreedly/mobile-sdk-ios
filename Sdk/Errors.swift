//
// Created by Eli Thompson on 5/4/20.
//

import Foundation

public struct SpreedlyError: Error, CustomStringConvertible {
    public var description: String {
        "SpreedlyError: \(message)"
    }

    public let message: String
}