//
//  ReqResDetailsController.swift
//  SampleApp
//
//  Created by Alex Korotkov on 1/15/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

import UIKit
import ThreeDSSDK

class ReqResDetailsController: UIViewController  {
  var uiScrollView = UIScrollView()
  var textView = UITextView()
  let tabs = ["Request", "Response"]
  var segmentControl: UISegmentedControl = UISegmentedControl()
  var requestInfo = ""
  var responseInfo = ""
  var button = UIBarButtonItem()
  var feedback = UINotificationFeedbackGenerator()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    segmentControl = UISegmentedControl(items: tabs)
    segmentControl.selectedSegmentIndex = 0
    segmentControl.addTarget(self, action: #selector(changeAction), for: .valueChanged)

    self.view.backgroundColor = .white
    textView.isEditable = false
    uiScrollView.isScrollEnabled = true
    self.view.addSubview(uiScrollView)
    uiScrollView.addSubview(segmentControl)
    uiScrollView.addSubview(textView)
    button = UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(copyText))
    
    self.navigationItem.rightBarButtonItem = button
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.isToolbarHidden = true
  }

  @objc func copyText(_ sender: Any?) {
    UIPasteboard.general.string = "request: \(requestInfo) \n response: \(responseInfo)"
    self.feedback.notificationOccurred(.success)
  }
  
  @objc func changeAction(sender: UISegmentedControl) {
      switch sender.selectedSegmentIndex {
      case 0:
        textView.text = requestInfo
      default:
        textView.text = responseInfo
      }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    segmentControl.selectedSegmentIndex = 0
    textView.text = requestInfo
  }
  
  override func viewDidLayoutSubviews() {
    let frame = self.view.bounds
    segmentControl.frame = CGRect(x: frame.minX + 10, y: 10, width: frame.width - 20, height: 34)
    uiScrollView.frame = frame
    textView.frame = CGRect(x: segmentControl.frame.minX, y: segmentControl.frame.maxY, width: frame.width - 20, height: self.view.bounds.height)
    
    uiScrollView.contentSize = self.view.frame.size
  }
}
