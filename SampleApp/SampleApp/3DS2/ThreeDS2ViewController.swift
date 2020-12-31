//
//  SampleCardKPaymentView.swift
//  SampleApp
//
//  Created by Alex Korotkov on 5/28/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//

import UIKit
import CardKit

class ThreeDS2ViewController: UITableViewController, AddLogDelegate {
  var button = UIButton()
  var cleanButton = UIButton()
  var toolBar = UIToolbar()
  var headerView = UIView()
  var textFieldBaseUrl = UITextField()
  static var logs: NSMutableArray = NSMutableArray()
  var orderId: String = "";
  var seToken: String = "";
  var threeDSServerTransId: String = "";
  var threeDSSDKKey: String = "";
  var encriptedDeviceData: String = "";
  let transactionManager: TransactionManager = TransactionManager()
  var aRes = ["threeDSServerTransID": "", "acsTransID": "", "acsReferenceNumber": "", "acsSignedContent": ""]
  static var requestParams: RequestParams = RequestParams();
  
  func addLog(title: String, log: String) {
    ThreeDS2ViewController.logs.add(["title": title, "log": log])
    
    self.tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    transactionManager.delegate2 = self
    textFieldBaseUrl.text = url
    textFieldBaseUrl.backgroundColor = .white
    button.setTitle("Старт", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
    
    cleanButton.setTitle("Очистить", for: .normal)
    cleanButton.setTitleColor(.systemBlue, for: .normal)
    cleanButton.addTarget(self, action: #selector(pressedCleanButton), for: .touchUpInside)
    
    headerView.addSubview(textFieldBaseUrl)
    self.tableView.tableHeaderView = headerView
  
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 44

    
    self.tableView.backgroundColor = .white
    self.tableView.separatorStyle = .none
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.setNeedsLayout()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    
    let doneButton = UIBarButtonItem(title: "Старт", style: .plain, target: self, action: #selector(pressedButton))

    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let cancelButton = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action: #selector(pressedCleanButton))
    
    self.setToolbarItems([cancelButton,spaceButton, doneButton], animated: false)

    self.navigationController?.isToolbarHidden = false
    
    CardKConfig.shared.theme = CardKTheme.light();
    CardKConfig.shared.language = "";
    CardKConfig.shared.bindingCVCRequired = true;
    CardKConfig.shared.bindings = [];
    CardKConfig.shared.isTestMod = true;
    CardKConfig.shared.mdOrder = "mdOrder";
    CardKConfig.shared.mrBinApiURL = "https://mrbin.io/bins/display";
    CardKConfig.shared.mrBinURL = "https://mrbin.io/bins/";
    
    self.view.backgroundColor = CardKTheme.light().colorTableBackground;
  }
  
  @objc func pressedCleanButton() {
    ThreeDS2ViewController.logs.removeAllObjects()
    self.tableView.reloadData()
  }
  
  @objc func pressedButton() {
    url = textFieldBaseUrl.text ?? url
    
    ThreeDS2ViewController.requestParams.amount = "2000"
    ThreeDS2ViewController.requestParams.userName = "3ds2-api"
    ThreeDS2ViewController.requestParams.password = "testPwd"
    ThreeDS2ViewController.requestParams.returnUrl = "../merchants/rbs/finish.html"
    ThreeDS2ViewController.requestParams.failUrl = "errors_ru.html"
    ThreeDS2ViewController.requestParams.email = "test@test.ru"
    ThreeDS2ViewController.requestParams.text = "DE DE"
    ThreeDS2ViewController.requestParams.threeDSSDK = "true"
    
    API.registerNewOrder(params: ThreeDS2ViewController.requestParams) { [weak self] (data) in
      ThreeDS2ViewController.requestParams.orderId = data.orderId
      CardKConfig.shared.mdOrder = data.orderId ?? ""
    }
    
    let controller = CardKViewController();
    controller.cKitDelegate = self;
    
    let createdUiController = CardKViewController.create(self, controller: controller);
    
    
    let navController = UINavigationController(rootViewController: createdUiController)
    
    if #available(iOS 13.0, *) {
      self.present(navController, animated: true)
      return;
    }
    
    navController.modalPresentationStyle = .formSheet

    let closeBarButtonItem = UIBarButtonItem(
     title: "Close",
     style: .done,
     target: self,
     action: #selector(_close(sender:))
    )
    createdUiController.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.present(navController, animated: true)
  }
  
  override func viewDidLayoutSubviews() {
    textFieldBaseUrl.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
    
    headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
    self.tableView.tableHeaderView?.frame = headerView.frame
    self.navigationController?.isNavigationBarHidden = false
  }
  
  func _test() {
    
    API.sePayment(params: ThreeDS2ViewController.requestParams) { [weak self] (data, responseJSON) in
      DispatchQueue.main.async {
        self?.addLog(title: "Response: Payment", log: String(describing: responseJSON) )
        guard let data = data else {
          self?.transactionManager.close()
          return
        }
        
        ThreeDS2ViewController.requestParams.threeDSSDKKey = data.threeDSSDKKey
        ThreeDS2ViewController.requestParams.threeDSServerTransId = data.threeDSServerTransId
        
        self?.transactionManager.pubKey = data.threeDSSDKKey ?? ""
        self?.transactionManager.initializeSdk()
        TransactionManager.sdkProgressDialog?.show()
        ThreeDS2ViewController.requestParams.authParams = self!.transactionManager.getAuthRequestParameters()
        
        
        self?.addLog(title: "Request: Payment step 2", log: String(describing: ThreeDS2ViewController.requestParams))
        
        API.sePaymentStep2(params: ThreeDS2ViewController.requestParams) { [weak self] (data, responseJSON) in
          
          self?.addLog(title: "Response: Payment step 2", log: String(describing: responseJSON) )

          guard let data = data else {
            self?.transactionManager.close()
            return
          }
                      
          self?.aRes["threeDSServerTransID"] = ThreeDS2ViewController.requestParams.threeDSServerTransId ?? ""
          self?.aRes["acsTransID"] = data.acsTransID
          self?.aRes["acsReferenceNumber"] = data.acsReferenceNumber
          self?.aRes["acsSignedContent"] = data.acsSignedContent

          let aRes: ARes = ARes(JSON: self!.aRes)!;
          
          self?.transactionManager.handleResponse(responseObject: aRes)
        }
      }
    }
  }
  
  @objc func _close(sender:UIButton){
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
    
    let log = ThreeDS2ViewController.logs[indexPath.item] as! [String: String]
    
    cell.textLabel?.text = "\(log["title"] ?? "") \n \(log["log"] ?? "")"
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.lineBreakMode = .byWordWrapping

    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ThreeDS2ViewController.logs.count
  }

  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension ThreeDS2ViewController: CardKDelegate {
  func cardKPaymentView(_ paymentView: CardKPaymentView, didAuthorizePayment pKPayment: PKPayment) {
  
  }
  
  func cardKitViewController(_ controller: UIViewController, didCreateSeToken seToken: String, allowSaveBinding: Bool, isNewCard: Bool) {
    debugPrint(seToken)

    let alert = UIAlertController(title: "SeToken", message: "allowSaveCard = \(allowSaveBinding) \n isNewCard = \(isNewCard) \n seToken = \(seToken)", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

    ThreeDS2ViewController.requestParams.seToken = seToken
    
    self.dismiss(animated: true, completion: nil)
    _test()
  }
  
  func willShow(_ paymentView: CardKPaymentView) {
    let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
    let paymentItem = PKPaymentSummaryItem.init(label: "Коробка", amount: NSDecimalNumber(value: 0.1))
    let merchandId = "merchant.cardkit";
    paymentView.merchantId = merchandId
    paymentView.paymentRequest.currencyCode = "RUB"
    paymentView.paymentRequest.countryCode = "RU"
    paymentView.paymentRequest.merchantIdentifier = merchandId
    paymentView.paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
    paymentView.paymentRequest.supportedNetworks = paymentNetworks
    paymentView.paymentRequest.paymentSummaryItems = [paymentItem]
    paymentView.paymentButtonStyle = .black;
    paymentView.paymentButtonType = .buy;
    
    paymentView.cardPaybutton.backgroundColor = .white;
    paymentView.cardPaybutton.setTitleColor(.black, for: .normal);
    paymentView.cardPaybutton.setTitle("Custom title", for: .normal);
  }
  
  func didLoad(_ controller: CardKViewController) {
    controller.allowedCardScaner = CardIOUtilities.canReadCardWithCamera();
    controller.purchaseButtonTitle = "Custom purchase button";

    controller.displayCardHolderField = true;
    controller.allowSaveBinding = true;
    controller.isSaveBinding = false;

  }
  
  func cardKitViewControllerScanCardRequest(_ controller: CardKViewController) {

  }
}
