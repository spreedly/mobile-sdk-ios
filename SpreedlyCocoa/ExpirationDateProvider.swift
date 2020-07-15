//
// Created by Eli Thompson on 6/29/20.
//

@objc(SPRExpirationDateProvider)
public protocol ExpirationDateProvider: class {
    func expirationDate() -> ExpirationDate?
}

@objc(SPRExpirationDate)
public class ExpirationDate: NSObject {
    @objc let month: Int
    @objc let year: Int

    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
}
