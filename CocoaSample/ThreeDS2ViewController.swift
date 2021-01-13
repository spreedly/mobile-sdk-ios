//
//  ThreeDS2ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 10/29/20.
//

import Foundation
import PassKit
import UIKit
import Spreedly
import Spreedly3DS2
import SpreedlyCocoa

class ThreeDS2ViewController: UIViewController {
    @IBOutlet weak var cardNumber: SecureTextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var status: UILabel?
    @IBOutlet weak var challengeType: UISegmentedControl?

    override func viewDidLoad() {
        cardNumber.text = "5555555555554444"
        amount.text = "1000.00"
        status?.text = ""
    }

}

func safeDebugPrint(_ item: Any?, separator: String = " ", terminator: String = "\n") {
    if let item = item {
        debugPrint(item, separator: separator, terminator: terminator)
    }
}

extension ThreeDS2ViewController: ThreeDSTransactionRequestDelegate {
    func success(status: String) {
        self.status?.text = "success: \(status)"
        safeDebugPrint(self.status?.text)
    }

    func cancelled() {
        status?.text = "cancelled"
    }

    func timeout() {
        status?.text = "timeout"
    }

    func error(_ error: ThreeDSError) {
        safeDebugPrint(error)
        status?.text = "error: \(error)"
    }

    @IBAction func start3DS2(_ sender: Any) {
        start3DS2(withTheme: nil)
    }


    @IBAction func start3DS2BlackAndWhite(_ sender: Any) {
        let white = "FFFFFF"
        let gray = "7f7f7f"
        let black = "060606"
        let theme = SpreedlyTheme()
        theme.buttonPositiveBackgroundColor = black
        theme.buttonNeutralBackgroundColor = black
        theme.buttonPositiveTextColor = white
        theme.buttonNeutralTextColor = white
        theme.textBoxBorderColor = black
        theme.toolbarTextColor = white
        theme.toolbarColor = black
        theme.headingTextColor = black
        theme.textColor = black
        theme.textBoxCornerRadius = 0
        theme.buttonCornerRadius = 0
        start3DS2(withTheme: theme)
    }

    func start3DS2(withTheme theme: SpreedlyTheme?) {
        status?.text = "starting"
        let client = ClientFactory.create(with: ClientConfiguration(
                envKey: ProcessInfo.processInfo.environment["ENV_KEY"] ?? "A54wvT9knP8Sc6ati68epUcq72l",
                envSecret: ProcessInfo.processInfo.environment["ENV_SECRET"] ?? "0f0Cpq17bb5mAAUxtx0QmY2mXyHnEk26uYTrPttn4PIMKZC4zdTJVJSk4YHbe1Ij",
                test: true
        ))

        do {
            try ThreeDS.initialize(uiViewController: self, test: true, theme: theme)
        } catch {
            safeDebugPrint(error)
        }

        tokenize(client).subscribe(onSuccess: { tokenized in
            do {
                let creditCard = tokenized.creditCard!
                let _3ds2 = try ThreeDS.createTransactionRequest(cardType: creditCard.cardType ?? "master")
                _3ds2.delegate = self

                self.serversidePurchase(client, device_info: _3ds2.serialize(), token: creditCard.token!, scaProviderKey: "M8k0FisOKdAmDgcQeIKlHE7R1Nf", onSuccess: { scaAuthentication in
                    if scaAuthentication["state"] as? String == "failed" {
                        self.error(ThreeDSError.runtimeError(message: (scaAuthentication["flow_performed"] as? String) ?? "oops"))
                    } else {
                        _3ds2.doChallenge(withScaAuthentication: scaAuthentication)
                    }
                }, onError: { error in
                    safeDebugPrint("start depth 3")
                    safeDebugPrint(error)
                })
            } catch {
                safeDebugPrint("start depth 2")
                safeDebugPrint(error)
            }
        }, onError: { error in
            safeDebugPrint("start depth 1")
            safeDebugPrint(error)
        })
    }

    func tokenize(_ client: SpreedlyClient) -> SingleTransaction {
        let info = CreditCardInfo()
        info.firstName = "Dolly"
        info.lastName = "Dog"
        info.number = SpreedlySecureOpaqueStringBuilder.build(from: cardNumber.text)
        info.verificationValue = SpreedlySecureOpaqueStringBuilder.build(from: "919")
        info.year = 2029
        info.month = (challengeType?.selectedSegmentIndex ?? 0) + 1
        info.email = "dolly@dog.com"

        return client.createPaymentMethodFrom(creditCard: info)
    }

    func serversidePurchase(_ client: SpreedlyClient, device_info: String, token: String, scaProviderKey: String, onSuccess: @escaping (([String: Any]) -> Void), onError: @escaping ((Error) -> Void)) {
        self.status?.text = "serverSideStuff"
        let session = self.session(client.config)
        var request = URLRequest(url: URL(string: "https://core.spreedly.com/v1/gateways/BkXcmxRDv8gtMUwu5Buzb4ZbqGe/purchase.json")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "transaction": [
                "payment_method_token": token,
                "amount": Int((Double(amount.text ?? "1000.00") ?? 1000.00) * 100),
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
                    safeDebugPrint(String(data: data, encoding: .utf8))
                    safeDebugPrint(error)
                }
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let trans: [String: Any]? = json?["transaction"] as? [String: Any]
                if (try? trans?["state"] as? String) == "succeeded" {
                    DispatchQueue.main.async {
                        self.success(status: "frictionless success")
                    }
                    return
                }
                if let scaAuth = trans?["sca_authentication"] as? [String: Any] {
                    DispatchQueue.main.async {
                        onSuccess(scaAuth)
                    }
                    return
                }
                safeDebugPrint(String(data: data, encoding: .utf8) ?? "bad utf8")
                DispatchQueue.main.async {
                    onError(ThreeDSError.protocolError(message: "bad json"))
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    onError(error)
                }
            } else {
                DispatchQueue.main.async {
                    onError(ThreeDSError.protocolError(message: "unknown"))
                }
            }
        }
        task.resume()
    }

    private func session(_ config: ClientConfiguration) -> URLSession {
        var headers: [String: String] = ["Content-Type": "application/json"]
        headers["Authorization"] = "Basic \(encodedCredentials(config))"

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = headers
        let session = URLSession(configuration: config)
        return session
    }

    private func encodedCredentials(_ config: ClientConfiguration) -> String {
        let userPasswordString = "\(config.envKey):\(config.envSecret ?? "")"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        return userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}
