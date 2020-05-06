//
// Created by Stefan Rusek on 5/5/20.
//

import Foundation
import SwiftUI
import RxSwift
import Sdk

struct BankAccountForm: View {
    var disposeBag = DisposeBag()
    @State private var name = ""
    @State private var accountNumber = ""
    @State private var routingNumber = ""
    @State private var type = "checking"
    @State private var inProgress = false
    @State private var token: String? = nil
    @State private var error: String? = nil

    var body: some View {
        VStack {
            Text("Please Enter Your Bank Info")
            VStack {
                TextField("Name", text: $name).disabled(inProgress)
                TextField("Account Number", text: $accountNumber)
                        .keyboardType(.numberPad)
                        .disabled(inProgress)
                TextField("Routing Number", text: $routingNumber)
                        .keyboardType(.numberPad)
                        .disabled(inProgress)
            }.id(1)
            if token != nil {
                Text("Token: \(token!)")
            }
            if error != nil {
                Text("Error: \(error!)").foregroundColor(.red)
            }
            Button("Submit") {
                let client = createSpreedlyClient(env: secretEnvKey, secret: secretEnvSecret)
                var ba = BankAccount()
                ba.fullName = self.name
                ba.bankAccountNumber = self.accountNumber
                ba.routingNumber = self.routingNumber
                ba.bankAccountType = self.type
                self.inProgress = true
                self.token = nil
                self.error = nil
                client.createBankAccountPaymentMethod(bankAccount: ba, email: nil, data: nil, metadata: nil)
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