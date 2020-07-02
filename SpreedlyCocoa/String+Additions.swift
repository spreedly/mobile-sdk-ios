//
// Created by Eli Thompson on 5/28/20.
//

import Foundation

extension String {
    func onlyNumbers() -> String {
        String(self.filter { $0.isNumber })
    }

    func withoutSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "")
    }
}
