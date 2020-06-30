//
// Created by Eli Thompson on 6/23/20.
//

import UIKit

extension UIStackView {
    func addBackground(color: UIColor) {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(rect: bounds).cgPath
        shape.fillColor = color.cgColor
        layer.insertSublayer(shape, at: 0)
    }
}
