//
// Created by Eli Thompson on 7/1/20.
//

import UIKit

class SpinnerViewController: UIViewController {
    lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.largePre13)
        view.color = UIColor.labelPre13
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemBackgroundPre13.withAlphaComponent(0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func overlaySpinner(on controller: UIViewController) {
        controller.addChild(self)
        self.view.frame = controller.view.frame
        controller.view.addSubview(self.view)
        self.didMove(toParent: controller)
    }

    func removeSpinner() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
