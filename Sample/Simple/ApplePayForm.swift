//
// Created by Stefan Rusek on 5/5/20.
//

import Foundation
import SwiftUI
import PassKit
import RxSwift
import CoreSdk

struct ApplePayForm: View {
    var disposeBag = DisposeBag()

    @State private var inProgress = false
    @State private var error: String?
    @State private var token: String?

    let paymentHandler = PaymentHandler()

    var body: some View {
        VStack {
            Text("Tap to use Apple Pay")
            Button(action: {
                self.inProgress = true
                self.paymentHandler.startPayment { (success) in
                    if success {
                        print("Success")
                        self.token = self.paymentHandler.token
                    } else {
                        self.error = "Failed"
                    }
                    self.inProgress = false
                }
            }, label: {
                Text("PAY WITH  APPLE")
                        .font(Font.custom("HelveticaNeue-Bold", size: 16))
                        .padding(10)
                        .foregroundColor(.black)
            })

            if token != nil {
                Text("Token: \(token!)")
            }
            if error != nil {
                Text("Error: \(error!)").foregroundColor(.red)
            }
        }.padding(16)
    }
}

typealias PaymentCompletionHandler = (Bool) -> Void

class PaymentHandler: NSObject {

    static let supportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .masterCard,
        .visa
    ]

    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler?
    var token: String?
    var error: String?

    func startPayment(completion: @escaping PaymentCompletionHandler) {

        let amount = PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(string: "8.88"), type: .final)
        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.12"), type: .final)
        let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "10.00"), type: .final)

        paymentSummaryItems = [amount, tax, total];
        completionHandler = completion

        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = "merchant.com.ergonlabs.sample"
        paymentRequest.merchantCapabilities = [.capabilityCredit, .capabilityDebit, .capability3DS]
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        paymentRequest.requiredShippingContactFields = [.phoneNumber, .emailAddress]
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks

        // Display our payment request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
                self.completionHandler!(false)
            }
        })
    }
}

/*
    PKPaymentAuthorizationControllerDelegate conformance.
*/
extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {

        // Perform some very basic validation on the provided contact information
        if payment.shippingContact?.emailAddress == nil || payment.shippingContact?.phoneNumber == nil {
            NSLog("Shipping contact email or phone number were missing")
            paymentStatus = .failure
            completion(.failure)
        } else {
            let client = ClientFactory.create(envKey: secretEnvKey, envSecret: secretEnvSecret, test: true)
            let info = ApplePayInfo(firstName: "Dolly", lastName: "Dog", payment: payment)
            info.testCardNumber = "4111111111111111"

            _ = client.createApplePayPaymentMethod(applePay: info).subscribe(onSuccess: { transaction in
                let result = transaction.paymentMethod!
                guard result.errors.count == 0 else {
                    self.error = result.errors[0].message
                    self.paymentStatus = .failure
                    completion(.failure)
                    return
                }

                self.token = result.token!
                NSLog("Got payment method token: \(result.token!)")
                self.paymentStatus = .success
                completion(.success)
            }, onError: { error in
                self.error = "\(error)"
                self.paymentStatus = .failure
                completion(.failure)
            })
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completionHandler!(true)
                } else {
                    self.completionHandler!(false)
                }
            }
        }
    }
}
