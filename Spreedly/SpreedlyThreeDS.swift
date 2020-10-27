//
// Created by Stefan Rusek on 10/21/20.
//

import Foundation
import SDK3DS

public enum SpreedlyThreeDSError: Error {
    case invalidInput(message: String)
    case protocolError(message: String)
    case runtimeError(message: String)
    case unknownError(error: Error)
}

public class SpreedlyThreeDS {
    static let _3ds2service: ThreeDS2Service = ThreeDS2ServiceImpl.sdk

    public static func initialize(uiViewController: UIViewController, locale: String?) throws {
        let config = ConfigParameters()
        do {
            try _3ds2service.initialize(uiViewController: uiViewController, configParameters: config, locale: locale, uiCustomization: nil)
        } catch SDK3DSError.InvalidInputException(let message) {
            throw SpreedlyThreeDSError.invalidInput(message: message)
        } catch SDK3DSError.SDKAlreadyInitializedException {
            print("ERROR Already init")
            return
        }
    }

    public static func createTransactionRequest() throws -> SpreedlyThreeDSTransactionRequest {
        SpreedlyThreeDSTransactionRequest(_3ds2service, try _3ds2service.createTransaction(directoryServerID: "F000000000", messageVersion: "2.1.0"))
    }
}

public protocol SpreedlyThreeDSTransactionRequestDelegate {
    func success(status: String)

    func cancelled()

    func timeout()

    func error(_ error: SpreedlyThreeDSError)
}

public class SpreedlyThreeDSTransactionRequest {

    let service: SDK3DS.ThreeDS2Service
    let transaction: SDK3DS.Transaction

    public var delegate: SpreedlyThreeDSTransactionRequestDelegate?

    public init(_ service: SDK3DS.ThreeDS2Service, _ transaction: SDK3DS.Transaction) {
        self.service = service
        self.transaction = transaction
    }

    public func serialize() -> [String: Any] {
        let request = transaction.getAuthenticationRequestParameters()
        return [
            "sdk_app_id": request.getSDKAppID(),
            "sdk_enc_data": request.getDeviceData(),
            "sdk_ephem_pub_key": (try? JSONSerialization.jsonObject(with: request.sdkEphemeralPublicKey.data(using: .utf8)!, options: .allowFragments)) ?? "bad public key",
            "sdk_max_timeout": "15",
            "sdk_reference_number": request.sdkReferenceNumber,
            "sdk_trans_id": request.sdkTransactionID,
            "device_render_options": [
                "sdk_interface": "03",
                "sdk_ui_type": "01"
            ]
        ] as [String: Any]
    }

    public func serializeToJson() -> Data {
        try! JSONSerialization.data(withJSONObject: serialize())
    }

    public func doChallenge(threeDSServerTransactionID: String, acsTransactionID: String, acsRefNumber: String, acsSignedContent: String) {
        let parameters = SDK3DS.ChallengeParameters()
        parameters.threeDSServerTransactionID = threeDSServerTransactionID
        parameters.acsTransactionID = acsTransactionID
        parameters.acsRefNumber = acsRefNumber
        parameters.acsSignedContent = acsSignedContent
        do {
            try transaction.doChallenge(challengeParameters: parameters, challengeStatusReceiver: self, timeout: 15)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.error(.unknownError(error: error))
            }
        }
    }

}

extension SpreedlyThreeDSTransactionRequest: ChallengeStatusReceiver {

    public func completed(_ e: CompletionEvent) {
        delegate?.success(status: e.transactionStatus)
    }

    public func cancelled() {
        delegate?.cancelled()
    }

    public func timedout() {
        delegate?.timeout()
    }

    public func protocolError(_ e: ProtocolErrorEvent) {
        delegate?.error(.protocolError(message: e.ErrorMsg.getErrorDescription()))
    }

    public func runtimeError(_ e: RuntimeErrorEvent) {
        delegate?.error(.runtimeError(message: e.getErrorMessage()))
    }
}

