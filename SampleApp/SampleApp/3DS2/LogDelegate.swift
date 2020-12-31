//
//  LogDelegate.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/14/20.
//

import UIKit

/// Logger output protocol for listening to new log messages to arrive
public protocol LogDelegate {
    
    /// Triggered whenever a new log entry has been added.
    /// Use for to display the output of the log elsewhere or the act upon it in any other way than the default one.
    /// - parameter level: level of severity
    /// - parameter level: log message
    func logUpdate( message: LogMessage)
   
}

public class LogMessage: NSObject {
    @objc public var level: String = ""
    @objc public var message: String = ""
}

