//
// Created by Stefan Rusek on 5/5/20.
//

import Foundation
import SwiftUI
import RxSwift
import Sdk

struct CreditCardForm: View {
    var disposeBag = DisposeBag()
    @State private var name = ""
    @State private var cc = ""
    @State private var ccv = ""
    @State private var inProgress = false
    @State private var token: String? = nil
    @State private var error: String? = nil

    var body: some View {
        VStack {
            Text("Please Enter Your Card Info")
            VStack {
                TextField("Name", text: $name).disabled(inProgress)
                TextField("CC", text: $cc).disabled(inProgress)
                TextField("CCV", text: $ccv).disabled(inProgress)
            }.id(0)
            if token != nil {
                Text("Token: \(token!)")
            }
            if error != nil {
                Text("Error: \(error!)").foregroundColor(.red)
            }
            Button("Submit") {
                let client = createSpreedlyClient(env: secretEnvKey, secret: secretEnvSecret)
                var cc = CreditCard()
                cc.fullName = self.name
                cc.number = self.cc
                cc.verificationValue = self.ccv
                self.inProgress = true
                self.token = nil
                self.error = nil
                client.createCreditCardPaymentMethod(creditCard: cc, email: nil, metadata: nil, retained: true)
                        .subscribe(onSuccess: { transaction in
                            if transaction.succeeded {
                                self.token = transaction.token
                            } else {
                                self.error = transaction.message
                            }
                            self.inProgress = false
                        }, onError: { error in
                            self.error = "UNEXPECTED ERROR \(error)"
                            self.inProgress = false
                        }).disposed(by: self.disposeBag)
            }
        }.padding(16)
    }
}