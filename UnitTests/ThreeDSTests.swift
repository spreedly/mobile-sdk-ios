//
// Created by Stefan Rusek on 10/26/20.
//

import Foundation
import XCTest
@testable import Spreedly


class ThreeDsTests: XCTestCase {
    func testInit() throws {
        try SpreedlyThreeDS.initialize(uiViewController: UIViewController(), locale: nil)
    }

    func testCreate() throws {
        try SpreedlyThreeDS.initialize(uiViewController: UIViewController(), locale: nil)
        let trans = try SpreedlyThreeDS.createTransactionRequest()
        let data = trans.serialize()
        print(data)
        assert(data != nil)
    }
}
