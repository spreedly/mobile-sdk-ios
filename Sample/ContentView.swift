//
//  ContentView.swift
//  Sample
//
//  Created by Stefan Rusek on 5/5/20.
//
//

import SwiftUI
import Sdk

struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            SimpleForms()
                    .tabItem {
                        Text("Simple")
                    }
                    .tag(0)
            Text("Secure Input Coming Soon")
                    .font(.title)
                    .tabItem {
                        Text("Secure")
                    }
                    .tag(1)
        }
    }
}