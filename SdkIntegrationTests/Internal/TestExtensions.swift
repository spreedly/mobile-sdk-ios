//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import Sdk

enum TestError: Error {
    case unreachable
}

extension PrimitiveSequence where Trait == SingleTrait {
    func assertResult(_ test: XCTestCase) throws -> Element {
        var out: Element?
        let expectation = XCTestExpectation(description: "call returns a result")
        _ = self.subscribe(onSuccess: { result in
            XCTAssertNotNil(result)
            out = result
            expectation.fulfill()
        }, onError: { error in
            XCTFail("\(error)")
            expectation.fulfill()
        })
        test.wait(for: [expectation], timeout: 10.0)
        if let out = out {
            return out
        } else {
            XCTFail("NO RESULT!")
            throw TestError.unreachable
        }
    }
}
