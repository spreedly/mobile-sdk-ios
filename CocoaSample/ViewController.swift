//
//  ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 5/20/20.
//
//

import PassKit
import UIKit
@testable import Spreedly
import SpreedlyCocoa

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController {
    @IBAction public func launchExpress(_ sender: Any) {
        let builder = ExpressBuilder()
        builder.allowBankAccount = true
        builder.paymentMethods = [
            PaymentMethodItem(type: .creditCard, cardBrand: .visa, description: "Visa 1111", token: "abc456"),
            PaymentMethodItem(type: .creditCard, cardBrand: .amex, description: "Amex 1111", token: "abc456"),
            PaymentMethodItem(type: .creditCard, description: "Mastercard 1111", token: "abc456")
        ]
        builder.didSelectPaymentMethod = { item in
            print("Payment method selected token: \(item.token)")
            self.navigationController?.popToViewController(self, animated: true)
        }

        builder.paymentSelectionHeaderHeight = 100
        builder.paymentSelectionHeader = buildHeader()

        builder.paymentSelectionFooterHeight = 100
        builder.paymentSelectionFooter = buildFooter()

        builder.paymentRequest = buildPaymentRequest()

        let viewController = builder.buildViewController()
        navigationController?.show(viewController, sender: self)
    }

    private func buildHeader() -> UIView {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.text = "🎶 Sousa's Phones 📱"
        return label
    }

    private func buildFooter() -> UIView {
        let container = UIView(frame: .zero)

        let price = UILabel(frame: .zero)
        price.font = UIFont.preferredFont(forTextStyle: .title1)
        price.textColor = .systemBlue
        price.textAlignment = .center
        price.text = "$354.62"

        let description = UILabel(frame: .zero)
        description.font = UIFont.preferredFont(forTextStyle: .body)
        description.textAlignment = .center
        description.numberOfLines = 2
        description.text = [
            "Sax oPhone SE (2020)",
            "128GB, Polished Brass"
        ].joined(separator: "\n")

        container.addSubview(price)
        price.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            price.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            price.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            price.topAnchor.constraint(equalTo: container.topAnchor),
            price.heightAnchor.constraint(equalToConstant: 50)
        ])

        container.addSubview(description)
        description.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            description.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            description.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            description.topAnchor.constraint(equalTo: price.bottomAnchor),
            description.heightAnchor.constraint(equalToConstant: 50)
        ])

        return container
    }

    private func buildPaymentRequest() -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.ergonlabs.sample"
        request.merchantCapabilities = [
            .capabilityCredit,
            .capabilityDebit,
            .capability3DS
        ]
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.supportedNetworks = [
            .amex,
            .discover,
            .masterCard,
            .maestro,
            .elo,
            .cartesBancaires,
            .chinaUnionPay,
            .electron,
            .JCB,
            .visa
        ]

        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(string: "322.38"), type: .final),
            PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "32.24"), type: .final),
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "354.62"), type: .final)
        ]
        return request
    }

    @IBAction func expressWithPresent(_ sender: Any) {
        let builder = ExpressBuilder()
        builder.allowBankAccount = true
        builder.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "MC 4444", token: "abc456")
        ]
        builder.didSelectPaymentMethod = { item in
            print("Payment method selected token: \(item.token)")
            self.dismiss(animated: true)
        }
        builder.defaultCreditCardInfo = {
            let info = CreditCardInfo()
            info.fullName = "Full Name"
            return info
        }()
        builder.defaultBankAccountInfo = {
            let info = BankAccountInfo()
            info.firstName = "Firstname"
            info.lastName = "Lastname"
            info.accountHolderType = .business
            info.accountType = .savings
            return info
        }()
        builder.defaultApplePayInfo = {
            let info = PaymentMethodInfo()
            info.fullName = "Applepay Customer"
            info.address.address1 = "1 Infinite Loop"
            info.address.city = "Cupertino"
            info.address.state = "CA"
            info.address.zip = "95014"
            info.address.country = "US"
            info.address.phoneNumber = "8002752273"
            return info
        }()
        builder.presentationStyle = .asModal

        builder.paymentRequest = buildPaymentRequest()

        let viewController = builder.buildViewController()
        present(viewController, animated: true)
    }
}

extension ViewController : SpreedlyThreeDSTransactionRequestDelegate {
    func success(status: String) {
        let alert = UIAlertController(title: "Success", message: status, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func cancelled() {
        let alert = UIAlertController(title: "Cancelled", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func timeout() {
        let alert = UIAlertController(title: "Timeout", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func error(_ error: SpreedlyThreeDSError) {
        print(error)
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }


    @IBAction func start3DS2(_ sender: Any) {
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
                let _3ds2 = try SpreedlyThreeDS.createTransactionRequest(cardType: creditCard.cardType ?? "visa")
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
        info.number = SpreedlySecureOpaqueStringBuilder.build(from: "5555555555554444")
        info.verificationValue = SpreedlySecureOpaqueStringBuilder.build(from: "919")
        info.year = 2029
        info.month = 1
        info.email = "dolly@dog.com"

        return client.createPaymentMethodFrom(creditCard: info)
    }

    func serversidePurchase(_ client: SpreedlyClientImpl, device_info: String, token: String, scaProviderKey: String, onSuccess: @escaping (([String: Any]) -> Void), onError: @escaping ((Error) -> Void)) {
        let session = client.session(authenticated: true)
        var request = URLRequest(url: client.authenticatedPurchaseUrl("BkXcmxRDv8gtMUwu5Buzb4ZbqGe"))
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "transaction": [
                "payment_method_token": token,
                "amount": 3001,
                "currency_code": "USD",
                "redirect_url": "http://test.com/",
                "callback_url": "http://test.com/",
                "three_ds_version": "2",
                "device_info": device_info,
                "channel": "app",
                "sca_provider_key": scaProviderKey
            ] as [String: Any]
        ] as [String: Any])

        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                if let scaAuth = json?.object(optional: "transaction")?.object(optional: "sca_authentication") {
                    onSuccess(scaAuth)
                    return
                }
                print(String(data: data, encoding: .utf8) ?? "bad utf8")
                onError(SpreedlyThreeDSError.protocolError(message: "bad json"))
            } else if let error = error {
                onError(error)
            } else {
                onError(SpreedlyThreeDSError.protocolError(message: "unknown"))
            }
        }
        task.resume()
    }
}