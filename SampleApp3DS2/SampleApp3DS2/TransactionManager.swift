//
//  TransactionMeneger.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/14/20.
//

import UIKit
import ObjectMapper
import ThreeDSSDK


public protocol TransactionManagerDelegate: class {
    func errorEventReceived()
}

public class TransactionManager: NSObject, ChallengeStatusReceiver {

    @objc let TESTPLAN_2_2_PLUS = "2.2"
    @objc let HEADER_LABEL = "SECURE CHECKOUT"
    @objc let TOOLBAR_BACKGROUND = "#83ADD7"
    @objc static let instance = TransactionManager()
    static var sdkProgressDialog: ProgressDialog? = nil

    let logo:String = ""
    var pubKey: String = ""
    let rootKey: String = """
        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
    """
    var service: ThreeDS2Service? = nil
    var sdkTransaction: Transaction?
    @objc var isSdkInitialized: Bool = false
    //    @objc var psrqMessage : PSrq?
    var isChallengeTransaction : Bool? = false
    @objc var uiViewController: UIViewController?

    weak var delegate: TransactionManagerDelegate?
    
    @objc public func getSdkVersion() -> String {
        
        var result = "(Unknown)"
        self.initSdkOnce()
        if (service != nil){
            try? result = service!.getSDKVersion()
        }
        return result
    }

    @objc public func initializeSdk() {
        do {
            initSdkOnce()
            Log.i(object: self, message: "Create transaction for service")
            
            self.sdkTransaction = try self.service?.createTransaction(directoryServerID: "", messageVersion: "", publicKeyBase64: pubKey, rootCertificateBase64: rootKey, logoBase64: logo) as! Transaction

            
            TransactionManager.sdkProgressDialog = try self.sdkTransaction!.getProgressView()
        }
        catch _ {
           Log.e(object: self, message: "Error initializing SDK")
        }
    }
    
    @objc func initSdkOnce(){
        do {
            if (!self.isSdkInitialized){
                
                Log.i(object: self, message: "Initializing SDK")
//                ----
                let p = ConfigParameters()
                try! p.addParam(nil, ConfigParameters.Key.integrityReferenceValue.rawValue, "abc")
                let config = p
//                -----
                
                
                self.service = Ecom3DS2Service()
                let uiConfig = UiCustomization()
                // Customize Challenge Header Text
                let toolbarCustomization = ToolbarCustomization()
                try? toolbarCustomization.setHeaderText(HEADER_LABEL)
                try? toolbarCustomization.setBackgroundColor(TOOLBAR_BACKGROUND)
                uiConfig.setToolbarCustomization(toolbarCustomization)
                
                let locale = "en"
                
                try self.service!.initialize(configParameters: config, locale: locale, uiCustomization: uiConfig)
                self.isSdkInitialized = true
                Log.i(object: self, message: "Initialized SDK ----------")
            }
            else {
                Log.w(object: self, message: "SDK has already been initialized")
            }
        }
        catch _ {
            Log.e(object: self, message: "Error initializing SDK")
        }
    }
    
    func getAuthRequestParameters() -> ThreeDSSDK.AuthenticationRequestParameters {
        let authRequestParams = try! self.sdkTransaction!.getAuthenticationRequestParameters()
        print("encoded device info \(authRequestParams.getDeviceData())")
        print("ephem pub key \(authRequestParams.getSDKEphemeralPublicKey())")
        print("App id \(authRequestParams.getSDKAppID())")
        print("Transaction Id \(authRequestParams.getSDKTransactionID())")
        
        return authRequestParams;
       //        let encryptedDeviceInfo: String = authRequestParams.getDeviceData()
    }
    /*
     * Execute Authentication Request
     */
//    @objc public func startAResAResFlow(pAreq : PAReq, projectId :  String, uiViewController: UIViewController) {
//
//        testCaseRunner.updateOOBFlow(value: false)
//
//        Log.s(object: self, message: "Execute authentication Request")
//        self.uiViewController = uiViewController
//
//        // Setup SDK Authentication Request Parameters
//        let authRequestParams: ults_AuthenticationRequestParameters = try! self.sdkTransaction!.getAuthenticationRequestParameters()
//        let encryptedDeviceInfo: String = authRequestParams.getDeviceData()
//        let sdkTransactionId : String = authRequestParams.getSDKTransactionID()
//        let sdkEphemeralPublicKey : String = authRequestParams.getSDKEphemeralPublicKey()
//        let sdkReferenceNumber : String = authRequestParams.getSDKReferenceNumber()
//        let sdkAppID : String = authRequestParams.getSDKAppID()
//
//        pAreq.sdkTransID = sdkTransactionId
//        pAreq.sdkEphemPubKey = Mapper<SdkEphemPubKey>().map(JSONString: sdkEphemeralPublicKey)
//        pAreq.sdkReferenceNumber = sdkReferenceNumber
//        pAreq.sdkAppID = sdkAppID
//        pAreq.sdkEncData = encryptedDeviceInfo
//        pAreq.sdkMaxTimeout = "05"
//        pAreq.threeDSRequestorAuthenticationInd = "01"
//
//        Log.i(object: self, message: "10. RequesterConnector - areqRequest")
//        areqAresRequest = RequesterConnector(delegate: self, projectId: projectId, pAreq: pAreq)
//        areqAresRequest?.areqRequest()
//    }
//
    /*
     * AReq/ARes Callbacks
     */
//    @objc func onFailure(errorMessage: String) {
//        Log.e(object: self, message: "onFailure \(errorMessage)")
//        testFinished(segueIdentifier:SegueIdentifers.showResults, strTestMessage:localizedStrings.txtAReqError)
//    }
//
//    @objc func onResponse(responseObject: NSObject) {
//        areqAresRequest = nil
//        if (testCaseRunner.tcMessage != nil) {
//            handleResponse(responseObject: responseObject)
//        }
//    }
//
    
    @objc func testFinished() {
        Log.i(object: self, message: "Test has finished")
    
        TransactionManager.sdkProgressDialog?.close()
    }

    @objc func handleResponse (responseObject: NSObject){
        Log.i(object: self, message: "11. handle response")

        

            self.isChallengeTransaction = false
            let aRes = responseObject as! ARes

//            psrqMessage = PSrq()
//            psrqMessage?.messageVersion = aRes.messageVersion
//            psrqMessage?.threeDSServerTransID = aRes.threeDSServerTransID
//            psrqMessage?.p_messageVersion = aRes.p_messageVersion

            if (aRes.transStatus != nil){
                Log.i(object: self, message: "handle response for transStatus= \(aRes.transStatus!)")
            }

            switch (aRes.transStatus) {
                case "C"?:
                    Log.i(object: self, message: "12. create challenge parameters")
                    let challengeParameters = createChallengeParameters(aRes: aRes)
                    self.isChallengeTransaction = true
                    let timeout : Int32 =  5
//                    SDKChallengeDataProtocol.instance.challengeIteration = 0
                    executeChallenge(delegate: self, challengeParameters: challengeParameters , timeout: timeout)

                case "Y"?:
                    testFinished()
                case "A"?:
                    testFinished()
                case "N"?:
                    testFinished()
                case "U"?:
                    testFinished()
                case "R"?:
                    testFinished()
                default:
                    testFinished()
                }
        
    }

    func createChallengeParameters(aRes: ARes) -> ChallengeParameters{
        let challengeParameters = ChallengeParameters()
        challengeParameters.setAcsSignedContent(aRes.acsSignedContent!)
        challengeParameters.setAcsRefNumber(aRes.acsReferenceNumber!)
        challengeParameters.setAcsTransactionID(aRes.acsTransID!)
        challengeParameters.set3DSServerTransactionID(aRes.threeDSServerTransID!)


//        let appUrl = url
//        let autParams = try! self.sdkTransaction?.getAuthenticationRequestParameters()
//        let SDKTransactionId = autParams?.getSDKTransactionID()
//        if (SDKTransactionId != nil){
//            if (appUrl != nil && appUrl.count>0){
//                challengeParameters.setThreeDSRequestorAppURL("\(appUrl)\(SDKTransactionId!)")
//            }
//        }
        return challengeParameters
    }
//
//    @objc func onErrorResponse(errorMessage: String) {
//        Log.e(object: self, message: "onErrorResponse \(errorMessage)")
//        testFinished(segueIdentifier:SegueIdentifers.showResults, strTestMessage:localizedStrings.txtAResError)
//    }
//
//    /*
//     * Execute Challenge
//     */
    func executeChallenge(delegate: ChallengeStatusReceiver ,challengeParameters: ChallengeParameters, timeout : Int32) {

        DispatchQueue.main.async(){
            do {
                Log.s(object: self, message: "Execute challenge")
                try self.sdkTransaction?.doChallenge(challengeParameters: challengeParameters, challengeStatusReceiver: delegate, timeOut: Int(timeout))
            } catch {
//                dump(error)
//                self.sdkRuntimeException()
            }
        }
    }
//
//    /*
//     * CReq/CRes Callbacks
//     */
    public func completed(completionEvent e: CompletionEvent) {
        let transactionStatus : String? = e.getTransactionStatus()
        Log.i(object: self, message: "completed ")
        var strMessage : String

        switch transactionStatus {
            case "Y"?:
                
                strMessage = "Status Y"
            case "N"?:
                
                strMessage = "Status N"
            default:
                
                strMessage = "Status unknow"
            }

        testFinished()
    }

    @objc public func cancelled() {
        Log.w (object: self, message:  "TransactionManager - Cancelled")
        testFinished()
    }

    // ults_ChallengeStatusReceiver event
    @objc public func timedout() {
        Log.e(object: self, message: "TransactionManager - timedOut")
        
        delegate?.errorEventReceived()
        testFinished()
    }

    public func protocolError(protocolErrorEvent e: ProtocolErrorEvent) {
        Log.e(object: self, message: "TransactionManager - Protocol error")

        delegate?.errorEventReceived()
        testFinished()
    }

    public func runtimeError(_ e: ProtocolErrorEvent) {
        Log.e(object: self, message: "TransactionManager - run time error")
        delegate?.errorEventReceived()
        testFinished()
    }
    
    public func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
        
    }
    
//
//    @objc func sdkRuntimeException() {
//        Log.e(object: self, message: "TransactionManager - sdk run time exception")
//        psrqMessage?.p_runtimeErrorCode = "999"
//        psrqMessage?.p_runtimeErrorMessage = "SDKRuntime Exception"
//
//        delegate?.errorEventReceived()
//        testFinished(segueIdentifier:SegueIdentifers.showResults, strTestMessage: localizedStrings.txtChallengeRuntimeError)
//    }
//
//    /*
//     * Finish TestCase Execution and show Result Screen (!)
//     */
//    @objc func testFinished(segueIdentifier: String, strTestMessage: String) {
//        Log.i(object: self, message: "Test has finished")
//
//        areqAresRequest = nil
//        TransactionManager.sdkProgressDialog?.close()
//        finishTransaction()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if (self.testCaseRunner.hasNextPareq()) {
//                Log.i(object: self, message: "16. start transaction")
//                self.testCaseRunner.startTransaction(uiViewController: self.uiViewController!)
//            }
//            else {
//                Log.i(object: self, message: "17. show results")
//                Emvco3dsFramework.resultsViewController?.notify()
//            }
//        }
//    }
//
//    @objc func finishTransaction() {
//        Log.i(object: self, message: "15. Finish transaction")
//
//        do {
//            SDKChallengeDataProtocol.instance.challengeIteration = 0
//            if (!isChallengeTransaction!) {
//                Log.i(object: self, message: "close transaction")
//                try self.sdkTransaction!.close()
//            }
//            Log.i(object: self, message: "clean up")
//            if (self.isSdkInitialized) {
//                try self.service?.cleanup(nil)
//                self.isSdkInitialized = false
//            }
//        } catch _ {
//            Log.e(object: self, message: "Error on closing SDK transaction")
//        }
//    }
}

