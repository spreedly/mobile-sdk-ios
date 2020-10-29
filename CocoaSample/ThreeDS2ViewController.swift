//
//  ThreeDS2ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 10/29/20.
//

import Foundation
import PassKit
import UIKit
@testable import Spreedly
import SpreedlyCocoa

class ThreeDS2ViewController: UIViewController {
    @IBOutlet weak var cardNumber: SecureTextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var status: UILabel?

    override func viewDidLoad() {
        cardNumber.text = "5555555555554444"
        amount.text = "1000.00"
        status?.text = ""
    }

}

extension ThreeDS2ViewController: SpreedlyThreeDSTransactionRequestDelegate {
    func success(status: String) {
        self.status?.text = "success: \(status)"
    }

    func cancelled() {
        self.status?.text = "cancelled"
    }

    func timeout() {
        self.status?.text = "timeout"
    }

    func error(_ error: SpreedlyThreeDSError) {
        print(error)
        self.status?.text = "error: \(error)"
    }


    @IBAction func start3DS2(_ sender: Any) {
        self.status?.text = "starting"
        let client = ClientFactory.create(with: ClientConfiguration(
                envKey: ProcessInfo.processInfo.environment["ENV_KEY"] ?? "A54wvT9knP8Sc6ati68epUcq72l",
                envSecret: ProcessInfo.processInfo.environment["ENV_SECRET"] ?? "0f0Cpq17bb5mAAUxtx0QmY2mXyHnEk26uYTrPttn4PIMKZC4zdTJVJSk4YHbe1Ij",
                test: true
        ))

        do {
            try SpreedlyThreeDS.initialize(uiViewController: self)
        } catch {
            print(error)
        }

        tokenize(client).subscribe(onSuccess: { tokenized in
            do {
                let creditCard = tokenized.creditCard!
                let _3ds2 = try SpreedlyThreeDS.createTransactionRequest(cardType: creditCard.cardType ?? "mastercard")
                _3ds2.delegate = self

                self.serversidePurchase(client as! SpreedlyClientImpl, device_info: _3ds2.serialize(), token: creditCard.token!, scaProviderKey: "M8k0FisOKdAmDgcQeIKlHE7R1Nf", onSuccess: { scaAuthentication in
                    _3ds2.doChallenge(withScaAuthentication: scaAuthentication)
                }, onError: { error in
                    print(error)
                })
            } catch {
                print(error)
            }
        }, onError: { error in
            print(error)
        })
    }

    func tokenize(_ client: SpreedlyClient) -> SingleTransaction {
        let info = CreditCardInfo()
        info.firstName = "Dolly"
        info.lastName = "Dog"
        info.number = SpreedlySecureOpaqueStringBuilder.build(from: cardNumber.text)
        info.verificationValue = SpreedlySecureOpaqueStringBuilder.build(from: "919")
        info.year = 2029
        info.month = 1
        info.email = "dolly@dog.com"

        return client.createPaymentMethodFrom(creditCard: info)
    }

    func serversidePurchase(_ client: SpreedlyClientImpl, device_info: String, token: String, scaProviderKey: String, onSuccess: @escaping (([String: Any]) -> Void), onError: @escaping ((Error) -> Void)) {
        self.status?.text = "serverSideStuff"
        let session = client.session(authenticated: true)
        var request = URLRequest(url: client.authenticatedPurchaseUrl("BkXcmxRDv8gtMUwu5Buzb4ZbqGe"))
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "transaction": [
                "payment_method_token": token,
                "amount":  Int((Double(amount.text ?? "1000.00") ?? 1000.00) * 100),
                "currency_code": "EUR",
                "redirect_url": "http://test.com/",
                "callback_url": "http://test.com/",
                "device_info": device_info,
                "channel": "app",
                "sca_provider_key": scaProviderKey
            ] as [String: Any]
        ] as [String: Any])

        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                     self.success(status: "response: \(String(data: data, encoding: .utf8)) \(error)")
                 }
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let trans: [String: Any]? = json?.object(optional: "transaction")
                if (try? trans?.string(for: "state")) == "succeeded" {
                    DispatchQueue.main.async {
                        self.success(status: "frictionless success")
                    }
                    return
                }
                if let scaAuth = trans?.object(optional: "sca_authentication") {
                    DispatchQueue.main.async {
                        onSuccess(scaAuth)
                    }
                    return
                }
                print(String(data: data, encoding: .utf8) ?? "bad utf8")
                DispatchQueue.main.async {
                    onError(SpreedlyThreeDSError.protocolError(message: "bad json"))
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    onError(error)
                }
            } else {
                DispatchQueue.main.async {
                    onError(SpreedlyThreeDSError.protocolError(message: "unknown"))
                }
            }
        }
        task.resume()
    }
}
