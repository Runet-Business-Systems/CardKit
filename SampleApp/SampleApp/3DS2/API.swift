//
//  RestManager.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/18/20.
//

import Foundation
import ThreeDSSDK

struct RequestParams {
  var userName: String?
  var password: String?
  var amount: String?
  var returnUrl: String?
  var failUrl: String?
  var email: String?
  
  var orderId: String?
  var seToken: String?
  var text: String?
  var threeDSSDK: String?
  var threeDSServerTransId: String?
  var threeDSSDKKey: String?
  
  var authParams: ThreeDSSDK.AuthenticationRequestParameters?
}

struct ResponseParams {
  var orderId: String?
  var threeDSServerTransId: String?
  var threeDSSDKKey: String?
  
  var acsTransID: String?
  var acsReferenceNumber: String?
  var acsSignedContent: String?
}

var url = "https://web.rbsdev.com/soyuzpayment";
let pubKey = """
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----
    """

class API {
    static func registerNewOrder(params: RequestParams, completionHandler: @escaping (ResponseParams, Data) -> Void) {
      let headers = [
        "content-type": "application/x-www-form-urlencoded",
      ]

      let body = [
        "amount": params.amount ?? "",
        "userName": params.userName ?? "",
        "password": params.password ?? "",
        "returnUrl": params.returnUrl ?? "",
        "failUrl": params.failUrl ?? "",
        "email": params.email ?? "",
      ];

      var request = URLRequest(url: NSURL(string: "\(url)/rest/register.do")! as URL)
      request.httpMethod = "POST"
      request.allHTTPHeaderFields = headers
      request.encodeParameters(parameters: body)

      let session = URLSession.shared
      let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in

          guard let data = data else { return }
        
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

        if let responseJSON = responseJSON as? [String: Any] {
          var responseParams = ResponseParams()
          responseParams.orderId = (responseJSON["orderId"] as! String)
          completionHandler(responseParams, data)
        }
      })

      dataTask.resume()
  }

  static func sePayment(params: RequestParams, completionHandler: @escaping (ResponseParams?, Data) -> Void) {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    let body = [
      "seToken": params.seToken ?? "",
      "MDORDER": params.orderId ?? "",
      "userName": params.userName ?? "",
      "password": params.password ?? "",
      "TEXT": params.text ?? "",
      "threeDSSDK": params.threeDSSDK ?? "",
    ];

    var request = URLRequest(url: URL(string: "\(url)/rest/paymentorder.do")!)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.encodeParameters(parameters: body)

    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
      guard let data = data else {
//        completionHandler(nil, data)
        return
      }
      
      guard let responseJSON = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
        return
      }
      
      guard
        let threeDSSDKKey = responseJSON["threeDSSDKKey"] as? String,
        let threeDSServerTransId = responseJSON["threeDSServerTransId"] as? String
      else {
        completionHandler(nil, data)
        return
      }
      
      var responseParams = ResponseParams()

      responseParams.threeDSSDKKey = threeDSSDKKey
      responseParams.threeDSServerTransId = threeDSServerTransId
      
      completionHandler(responseParams, data)
    }).resume()
  }


  static func sePaymentStep2(params: RequestParams, completionHandler: @escaping (ResponseParams?, Data) -> Void) {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded",
    ]

    let body = [
      "seToken": params.seToken ?? "",
      "MDORDER": params.orderId ?? "",
      "threeDSServerTransId": params.threeDSServerTransId ?? "",
      "userName": params.userName ?? "",
      "password": params.password ?? "",
      "TEXT": params.text ?? "",
      "threeDSSDK": params.threeDSSDK ?? "",
      "threeDSSDKEncData": params.authParams!.getDeviceData(),
      "threeDSSDKEphemPubKey":params.authParams!.getSDKEphemeralPublicKey(),
      "threeDSSDKAppId": params.authParams!.getSDKAppID(),
      "threeDSSDKTransId": params.authParams!.getSDKTransactionID()
    ];

    var request = URLRequest(url: URL(string: "\(url)/rest/paymentorder.do")!)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.encodeParameters(parameters: body)

    let session = URLSession.shared
    session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in

      guard let data = data else { return }
      
      guard let responseJSON = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
        return
      }
      
      guard
        let acsTransID = responseJSON["threeDSAcsTransactionId"] as? String,
        let acsReferenceNumber = responseJSON["threeDSAcsRefNumber"] as? String,
        let acsSignedContent = responseJSON["threeDSAcsSignedContent"] as? String
      else {
        completionHandler(nil, data)
        return
      }
      
      var responseParams = ResponseParams()

      responseParams.acsTransID = acsTransID
      responseParams.acsReferenceNumber = acsReferenceNumber
      responseParams.acsSignedContent = acsSignedContent
      
      completionHandler(responseParams, data)
    }).resume()
  }

  static func finishOrder(params: RequestParams, completionHandler: @escaping (Any, Data) -> Void) {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded",
    ]

    let body = [
      "threeDSServerTransId": params.threeDSServerTransId ?? "",
      "userName": params.userName ?? "",
      "password": params.password ?? "",
    ];

    var request = URLRequest(url: URL(string: "\(url)/rest/finish3dsVer2Payment.do")!)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.encodeParameters(parameters: body)

    let session = URLSession.shared
    session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
      
      guard let data = data else { return }
      
        let responseJSON = try! JSONSerialization.jsonObject(with: data, options: [])
      
      let responseParams = ResponseParams()
      completionHandler(responseJSON, data)
    }).resume()
  }
  
  static func fetchOrderStatus(params: RequestParams, completionHandler: @escaping (Any, Data) -> Void) {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded",
    ]

    let body = [
      "seToken": params.seToken ?? "",
      "MDORDER": params.orderId ?? "",
      "threeDSServerTransId": params.threeDSServerTransId ?? "",
      "userName": params.userName ?? "",
      "password": params.password ?? "",
      "TEXT": params.text ?? "",
      "threeDSSDK": params.threeDSSDK ?? "",
      "threeDSSDKEncData": params.authParams!.getDeviceData(),
      "threeDSSDKEphemPubKey": params.authParams!.getSDKEphemeralPublicKey(),
      "threeDSSDKAppId": params.authParams!.getSDKAppID(),
      "threeDSSDKTransId": params.authParams!.getSDKTransactionID()
    ];

    let orderId = params.orderId ?? ""
    
    var request: URLRequest = URLRequest(url: URL(string: "\(url)/rest/getOrderStatusExtended.do?orderId=\(orderId)&userName=3ds2-api&password=testPwd")!)

    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.encodeParameters(parameters: body)

    let session = URLSession.shared
    
    session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
      guard let data = data else { return }

      let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

      if let responseJSON = responseJSON as? [String: Any] {
        print("fetchOrderStatus: \(responseJSON)")
      }
      var responseParams = ResponseParams()
      completionHandler(responseJSON, data)
    }).resume()
  }
}

extension URLRequest {
  private func percentEscapeString(_ string: String) -> String {
    var characterSet = CharacterSet.alphanumerics
    characterSet.insert(charactersIn: "-._* ")
    
    return string
      .addingPercentEncoding(withAllowedCharacters: characterSet)!
      .replacingOccurrences(of: " ", with: "+")
      .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
  }

  mutating func encodeParameters(parameters: [String : String]) {
    httpMethod = "POST"
    
    let parameterArray = parameters.map { (arg) -> String in
      let (key, value) = arg
      return "\(key)=\(self.percentEscapeString(value))"
    }
    
    httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
  }
}
