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

print("Getting gateway")
let BASE_URL = "https://core.spreedly.com"
let url = BASE_URL + Gateway.endpoint
try u.retrieve(url, completion: onGatewayComplete)
print("Done requesting gateway")

CFRunLoopRun()
