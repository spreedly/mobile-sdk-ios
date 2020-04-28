//
//  main.swift
//  SdkCli
//
//  Created by Eli Thompson on 4/23/20.
//  Copyright © 2020 Spreedly. All rights reserved.
//

import Foundation
import Sdk


func onGatewayComplete(response: GatewayResponse?, err: Error?) {
    if let err = err {
        print(err)
    }
    if let response = response {
        print(response)
    }
}

let ENV_KEY = ProcessInfo.processInfo.environment["ENV_KEY"]
let ENV_SECRET = ProcessInfo.processInfo.environment["ENV_SECRET"]

let u  = Util(envKey: ENV_KEY!, envSecret: ENV_SECRET!)
let BASE_URL = "https://core.spreedly.com"

func createCreditCard() {
    var cc = CreditCard()
    cc.firstName = "Dolly"
    cc.lastName = "Dog"
    cc.number = "4111111111111111"
    cc.month = "12"
    cc.year = "2022"
    cc.verificationValue = "999"
    cc.company = "Ranch"
    cc.address1 = "123 Fake St"
    cc.city = "Springfield"
    cc.state = "OR"
    cc.zip = "54321"
    cc.country = "US"

    var pm = PaymentMethod(creditCard: cc, email: "dolly@dog.com", metadata: ["somekey": "somevalue"])
    var ccr = CreateCreditCardRequest(paymentMethod: pm)
    do {
        try u.create(BASE_URL + "/v1/payment_methods.json", entity: ccr) { (ccr: CreditCardResponse?, err: Error?) -> Void in
            guard err == nil else {
                print("Unable to create credit card", err)
                return
            }

            if let ccr = ccr {
                print("CreditCardResponse returned", ccr)
            }
        }
    } catch {
        print("Unable to create credit card", error)
    }
}

func getCreditCard(token: String) {
    do {
        try u.retrieve(BASE_URL + "/v1/payment_methods/\(token).json") { (response: ShowCreditCardResponse?, err: Error?) in
            guard err == nil else {
                print("Unable to retrieve credit card", err)
                return
            }

            if let response = response {
                print("Response returned", response)
            }
        }
    } catch {
        print(error)
    }
}




//print("Getting gateway")

//let url = BASE_URL + Gateway.endpoint
//try u.retrieve(url, completion: onGatewayComplete)
//createCreditCard()
getCreditCard(token: "SWubuQiGAD1LuD7PBkk8t3pDkaS")
//print("Done requesting gateway")

CFRunLoopRun()
