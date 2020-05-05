//
// Created by Stefan Rusek on 5/5/20.
//

import SwiftUI

struct SimpleForms: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            CreditCardForm()
                    .tabItem {
                        Text("Credit Card")
                    }
                    .tag(0)
            BankAccountForm()
                    .tabItem {
                        Text("Bank Account")
                    }
                    .tag(1)
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
    }
}