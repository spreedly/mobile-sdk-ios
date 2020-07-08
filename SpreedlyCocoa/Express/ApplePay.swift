//
// Created by Eli Thompson on 7/6/20.
//

import PassKit
import Spreedly

public typealias PaymentCompletionHandler = (Bool, Transaction?) -> Void

@objc(SPRApplePayHandler)
public class ApplePayHandler: NSObject {
    private var paymentController: PKPaymentAuthorizationController?
    private var paymentStatus = PKPaymentAuthorizationStatus.failure
    private var completionHandler: PaymentCompletionHandler?
    private var client: SpreedlyClient?
    private var objcClient: _ObjCClient?
    private var error: String?
    private var token: String?
    private var transaction: Transaction?

    public init(client: SpreedlyClient) {
        self.client = client
    }

    @objc public init(client: _ObjCClient) {
        self.objcClient = client
    }

    @objc public func startPayment(request: PKPaymentRequest, completion: @escaping PaymentCompletionHandler) {
        self.completionHandler = completion

        paymentController = PKPaymentAuthorizationController(paymentRequest: request)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
                self.paymentController?.dismiss()
                self.completionHandler?(false, nil)
            }
        })
    }
}

extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
    public func paymentAuthorizationController(
            _ controller: PKPaymentAuthorizationController,
            didAuthorizePayment payment: PKPayment,
            completion: @escaping (PKPaymentAuthorizationStatus) -> Void
    ) {
        guard let firstName = payment.shippingContact?.name?.givenName,
                let lastName = payment.shippingContact?.name?.familyName else {
            NSLog("Name is missing")
            paymentStatus = .failure
            completion(.failure)
            return
        }

        let info = ApplePayInfo(firstName: firstName, lastName: lastName, payment: payment)
        _ = client?.createPaymentMethodFrom(applePay: info).subscribe(onSuccess: { transaction in
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

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        NSLog("paymentAuthorizationControllerDidFinish")
        controller.dismiss {
            DispatchQueue.main.async {
                self.completionHandler?(
                        self.paymentStatus == .success,
                        self.transaction
                )
            }
        }
    }
}
