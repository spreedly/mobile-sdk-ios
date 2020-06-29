//
// Created by Eli Thompson on 6/29/20.
//

@objc(SPRExpirationDateProvider) public protocol ExpirationDateProvider: class {
    func dateParts() -> DateParts?
}
