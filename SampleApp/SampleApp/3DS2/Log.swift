//
//  Log.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/14/20.
//

import UIKit

public class Log: NSObject {

    @objc public static let debugLevel = "d"
    @objc public static let screenLevel = "s"
    @objc public static let screenErrorLevel = "se"
    @objc public static let warningLevel = "w"
    @objc public static let errorLevel = "e"
    @objc public static let infoLevel = "i"
    
    public static var delegate : LogDelegate?
    
    /// Prints a line to the console output and notifies the log delegate.
    /// Use for debugging purposes specifically. There will be output only when debugging.
    /// - parameter object: calling instance, resulting in a class name to display in the output
    /// - returns: void
    @objc public static func d(object: NSObject, message:String){
        #if DEBUG
            print ("\(getTimeStamp()) \(getClassNameForObject(object: object)) \(message)")
            self.informDelegate(level: debugLevel, message: message)
        #endif
    }
    
    /// Prints a line to the console output and notifies the log delegate.
    /// Use for screen output purposes specifically.
    /// - parameter object: calling instance, resulting in a class name to display in the output
    /// - returns: void
    @objc public static func s(object: NSObject, message:String){
        print ("\(getTimeStamp()) \(getClassNameForObject(object: object)) \(message)")
        self.informDelegate(level: screenLevel, message: message)
    }
    
    /// Prints a line to the console output and notifies the log delegate.
    /// Use for screen error output purposes specifically.
    /// - parameter object: calling instance, resulting in a class name to display in the output
    /// - returns: void
    @objc public static func se(object: NSObject, message:String){
        print ("\(getTimeStamp()) \(getClassNameForObject(object: object)) \(message)")
        self.informDelegate(level: screenErrorLevel, message: message)
    }
    
    /// Prints a line to the console output and notifies the log delegate.
    /// Use for information messages only.
    /// - parameter object: calling instance, resulting in a class name to display in the output
    /// - returns: void
    @objc public static func i(object: NSObject, message:String){
        print ("\(getTimeStamp()) \(getClassNameForObject(object: object)) \(message)")
        self.informDelegate(level: infoLevel, message: message)
    }
    
    /// Prints a line to the console output and notifies the log delegate.
    /// Use for warning messages only.
    /// - parameter object: calling instance, resulting in a class name to display in the output
    /// - returns: void
    @objc public static func w(object: NSObject, message:String){
        print ("\(getTimeStamp()) \(getClassNameForObject(object: object)) \(message)")
        self.informDelegate(level: warningLevel, message: message)
    }
    
    /// Prints a line to the console output and notifies the log delegate.
    /// Use for error messages only.
    /// - parameter object: calling instance, resulting in a class name to display in the output
    /// - returns: void
    @objc public static func e(object: NSObject, message:String){
        print ("\(getTimeStamp()) \(getClassNameForObject(object: object)) \(message)")
        self.informDelegate(level: errorLevel, message: message)
    }
    
    private static func getTimeStamp() -> String{
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: currentDateTime)
    }
    
    private static func getClassNameForObject(object:NSObject)->String{
        let name = NSStringFromClass(type(of: object))+"."
        let elements = name.split(separator: ".")
        let result = String(describing: elements[elements.count-1]) as String
        return result
    }
    
    private static func informDelegate(level:String, message:String){
        let logMessage = LogMessage()
        logMessage.level = level
        logMessage.message = message
        delegate?.logUpdate(message: logMessage)
    }
}
