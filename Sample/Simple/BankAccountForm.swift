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
    @State private var bankAccountHolderType = "personal"
    @State private var inProgress = false
    @State private var token: String?
    @State private var error: String?

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
                let client = createSpreedlyClient(envKey: secretEnvKey, envSecret: secretEnvSecret, test: true)
                let baInfo = BankAccount()
                baInfo.fullName = self.name
                baInfo.bankAccountNumber = self.accountNumber
                baInfo.bankRoutingNumber = self.routingNumber
                baInfo.bankAccountType = self.type
                baInfo.bankAccountHolderType = self.bankAccountHolderType
                self.inProgress = true
                self.token = nil
                self.error = nil
                client.createBankAccountPaymentMethod(bankAccount: baInfo)
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
