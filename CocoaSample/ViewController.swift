//
//  ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 5/20/20.
//
//

import UIKit
import CocoaSdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func launchExpress(_ sender: Any) {
        let bundle = Bundle(for: SPSecureForm.self)
        let sb = UIStoryboard(name: "Express", bundle: bundle)
        let view = sb.instantiateInitialViewController()!
//        self.present(view, animated: true)
        self.navigationController?.pushViewController(view, animated: true)
    }
}
