//
//  ViewController.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/11/20.
//

import UIKit
import ThreeDSSDK
import CardKitCore

let url = "https://web.rbsdev.com/soyuzpayment/rest";
let pubKey = """
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----
    """

class ViewController: UIViewController {
  var orderId: String = "";
  var seToken: String = "";
  var threeDSServerTransId: String = "";
  var threeDSSDKKey: String = "";
  var encriptedDeviceData: String = "";
  let transactionManager: TransactionManager = TransactionManager()
  var authParams: ThreeDSSDK.AuthenticationRequestParameters? = nil
  var aRes = ["threeDSServerTransID": "", "acsTransID": "", "acsReferenceNumber": "", "acsSignedContent": ""]

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .red;
    registerNewOrder()
  }
  
  func registerNewOrder() {
      let headers = [
        "content-type": "application/x-www-form-urlencoded",
      ]
    
      let body = [
        "amount": "2000",
        "userName": "3ds2-api",
        "password": "testPwd",
        "returnUrl": "../merchants/rbs/finish.html",
        "failUrl": "errors_ru.html",
        "email": "test@test.ru",
      ];

      var request = URLRequest(url: NSURL(string: "\(url)/register.do")! as URL)
      request.httpMethod = "POST"
      request.allHTTPHeaderFields = headers
      request.encodeParameters(parameters: body)

      let session = URLSession.shared
      let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          
          guard let data = data else { return }
        
          let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

          if let responseJSON = responseJSON as? [String: Any] {
            print(responseJSON["orderId"] as! String)
            self.orderId = (responseJSON["orderId"] as! String)
            self.generateSeToken()
            self.sePayment()
          }
      })

      dataTask.resume()
  }
  
  func generateSeToken() {
    let cardParams = CKCCardParams();
    cardParams.cardholder = "Alex";
    cardParams.expiryMMYY = "1224";
    cardParams.pan = "4777777777777778";
    cardParams.cvc = "123";
    cardParams.mdOrder = self.orderId;
    cardParams.pubKey = pubKey;
    
    let res: CKCTokenResult = CKCToken.generate(withCard: cardParams);

    self.seToken = res.token!;
  }

  func sePayment() {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    let body = [
      "seToken": self.seToken,
      "MDORDER": self.orderId,
      "userName": "3ds2-api",
      "password": "testPwd",
      "TEXT": "DE DE",
      "threeDSSDK": "true",
    ];

    var request = URLRequest(url: URL(string: "\(url)/paymentorder.do")!)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.encodeParameters(parameters: body)

    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
      guard let data = data else { return }

      let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

      if let responseJSON = responseJSON as? [String: Any] {

        
        DispatchQueue.main.async {
          self.threeDSServerTransId = responseJSON["threeDSServerTransId"] as! String;
          self.threeDSSDKKey = responseJSON["threeDSSDKKey"] as! String;
          self.transactionManager.pubKey = self.threeDSSDKKey;
          self.transactionManager.initializeSdk()
          self.authParams = self.transactionManager.getAuthRequestParameters()
          self.sePaymentStep2()
        }
        
      }
    }).resume()
  }


  func sePaymentStep2() {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded",
    ]
    
    let body = [
      "seToken": self.seToken,
      "MDORDER": self.orderId,
      "threeDSServerTransId": self.threeDSServerTransId,
      "userName": "3ds2-api",
      "password": "testPwd",
      "TEXT": "DE DE",
      "threeDSSDK": "true",
      "threeDSSDKEncData": self.authParams?.getDeviceData() ?? "",
      "threeDSSDKEphemPubKey":self.authParams?.getSDKEphemeralPublicKey() ?? "",
      "threeDSSDKAppId": self.authParams?.getSDKAppID() ?? "",
      "threeDSSDKTransId": self.authParams?.getSDKTransactionID() ?? ""
    ];
    
    var request = URLRequest(url: URL(string: "\(url)/paymentorder.do")!)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.encodeParameters(parameters: body)

    print(body)

    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [self] (data, response, error) -> Void in
    
      guard let data = data else { return }
    
      let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

      if let responseJSON = responseJSON as? [String: Any] {
        print(responseJSON)
        self.aRes["threeDSServerTransID"] = self.threeDSServerTransId
        self.aRes["acsTransID"] = responseJSON["threeDSAcsTransactionId"] as! String
        self.aRes["acsReferenceNumber"] = responseJSON["threeDSAcsRefNumber"] as! String
        self.aRes["acsSignedContent"] = responseJSON["threeDSAcsSignedContent"] as! String
        self.aRes["transStatus"] = "C"
        
        let test: ARes = ARes(JSON: self.aRes)!;
        
        transactionManager.handleResponse(responseObject: test)
      }
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
