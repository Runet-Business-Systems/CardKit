//
//  ARes.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/14/20.
//

import UIKit
import ObjectMapper

class ARes: NSObject, Mappable{
    
    @objc var threeDSServerTransID: String?
    @objc var acsEphemPubKey: String?
    @objc var acsTransID: String?
    @objc var acsReferenceNumber: String?
    @objc var acsRenderingType: AcsRenderingType?
    @objc var acsSignedContent: String?
    @objc var acsURL: String?
    @objc var authenticationType: String?
    @objc var authenticationValue: String?
    @objc var challengeMandated: String?
    @objc var dsReferenceNumber: String?
    @objc var dsTransID: String?
    @objc var eci: String?
    @objc var ireqCode: String?
    @objc var ireqDetail: String?
    @objc var messageExtension: String?
    
    @objc var messageType: String?
    @objc var messageVersion: String?
    @objc var sdkEphemPubKey: SdkEphemPubKey?
    @objc var sdkTransID: String?
    @objc var transStatus: String?
    @objc var transStatusReason: String?
    @objc var errorCode: String?
    @objc var challengeCompletionInd: String?
    @objc var p_messageVersion: String?
    
    @objc var timestamp: String?
    @objc var status: String?
    @objc var acschallengeMandated: String?
   
    required init? (map: Map){
        // required init to be conform with the Mappable protocol
    }
    
    func mapping(map: Map) {
        threeDSServerTransID <- map["threeDSServerTransID"]
        acsEphemPubKey <- map["acsEphemPubKey"]
        acsTransID <- map["acsTransID"]
        acsReferenceNumber <- map["acsReferenceNumber"]
        acsRenderingType <- map["acsRenderingType"]
        acsSignedContent <- map["acsSignedContent"]
        acsURL <- map["acsURL"]
        authenticationType <- map["authenticationType"]
        authenticationValue <- map["authenticationValue"]
        challengeMandated <- map["challengeMandated"]
        dsReferenceNumber <- map["dsReferenceNumber"]
        dsTransID <- map["dsTransID"]
        eci <- map["eci"]
        ireqCode <- map["ireqCode"]
        ireqDetail <- map["ireqDetail"]
        messageExtension <- map["messageExtension"]
        
        messageType <- map["messageType"]
        messageVersion <- map["messageVersion"]
        sdkEphemPubKey <- map["sdkEphemPubKey"]
        sdkTransID <- map["sdkTransID"]
        transStatus <- map["transStatus"]
        transStatusReason <- map["transStatusReason"]
        errorCode <- map["errorCode"]
        challengeCompletionInd <- map["challengeCompletionInd"]
        p_messageVersion <- map["p_messageVersion"]
        
        timestamp <- map["timestamp"]
        status <- map["status"]
        acschallengeMandated <- map["acschallengeMandated"]
    }
}


class AcsRenderingType: NSObject, Mappable {
    @objc var inteface: String?
    @objc var uiType: String?
    
    required init? (map: Map){
        // required init to be conform with the Mappable protocol
    }
    
    func mapping(map: Map) {
        inteface <- map["interface"]
        uiType <- map["uiType"]
    }
}

class SdkEphemPubKey: NSObject, Mappable {
    @objc var kty: String?
    @objc var crv: String?
    @objc var x: String?
    @objc var y: String?
    
    required init?(map : Map) {
        // required init to be conform with the Mappable protocol
    }
    
    func mapping(map: Map) {
        kty <- map["kty"]
        crv <- map["crv"]
        x <- map["x"]
        y <- map["y"]
    }
}
