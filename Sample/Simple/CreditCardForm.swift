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
    @State private var ccNumber = ""
    @State private var ccv = ""
    @State private var year = ""
    @State private var month = ""
    @State private var inProgress = false
    @State private var token: String?
    @State private var error: String?

    var body: some View {
        VStack {
            Text("Please Enter Your Card Info")
            VStack {
                TextField("Name", text: $name).disabled(inProgress)
                TextField("CC", text: $ccNumber)
                        .keyboardType(.numberPad)
                        .disabled(inProgress)
                TextField("CCV", text: $ccv)
                        .keyboardType(.numberPad)
                        .disabled(inProgress)
                TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                        .disabled(inProgress)
                TextField("Month", text: $month)
                        .keyboardType(.numberPad)
                        .disabled(inProgress)
            }.id(0)
            if token != nil {
                Text("Token: \(token!)")
            }
            if error != nil {
                Text("Error: \(error!)").foregroundColor(.red)
            }
            Button("Submit") {
                let client = createSpreedlyClient(envKey: secretEnvKey, envSecret: secretEnvSecret, test: true)
                if let year = Int(self.year),
                   let month = Int(self.month) {
                    let ccInfo = CreditCardInfo(
                            fullName: self.name,
                            number: client.createSecureString(from: self.ccNumber),
                            verificationValue: client.createSecureString(from: self.ccv),
                            year: year,
                            month: month
                    )
                    self.inProgress = true
                    self.token = nil
                    self.error = nil
                    client.createCreditCardPaymentMethod(creditCard: ccInfo)
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
                } else {
                    self.error = "Month/Year required"
                }
            }
        }.padding(16)
    }
}
