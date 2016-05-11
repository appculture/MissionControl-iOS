//
//  ACCloudConfig.swift
//  ACCloudConfig
//
//  Created by Marko Tadic on 5/11/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation

public typealias ThrowConfigWithInnerBlock = (config: () throws -> [String : AnyObject]) -> Void

public class CloudConfig {
    
    public enum Error: ErrorType {
        case NoInternet
        case BadResponse
    }
    
    public struct Notification {
        static let ConfigLoaded = "ConfigLoaded"
        static let ConfigRefreshed = "ConfigRefreshed"
        static let ConfigSyncFailed = "ConfigSyncFailed"
    }
    
    public class var lastSyncDate: NSDate? {
        return ACCloudConfig.sharedInstance.lastSyncDate
    }
    
    public class var settings: [String : AnyObject] {
        return ACCloudConfig.sharedInstance.settings ?? [String : AnyObject]()
    }
    
    public class func launchWithOptions(localConfig: [String : AnyObject]? = nil, remoteConfigURL url: NSURL? = nil) {
        ACCloudConfig.sharedInstance.settings = localConfig
        ACCloudConfig.sharedInstance.remoteURL = url
    }
    
    public class func sync(completion: ThrowConfigWithInnerBlock? = nil) {
        ACCloudConfig.sharedInstance.sync(completion)
    }
    
}

public func CloudInteger(key: String, _ defaultValue: Int) -> Int {
    return defaultValue
}

public func CloudDouble(key: String, _ defaultValue: Double) -> Double {
    return defaultValue
}

public func CloudBool(key: String, _ defaultValue: Bool) -> Bool {
    return defaultValue
}

public func CloudString(key: String, _ defaultValue: String) -> String {
    return defaultValue
}

private class ACCloudConfig {
    
    static let sharedInstance = ACCloudConfig()
    
    var lastSyncDate: NSDate?
    var settings: [String : AnyObject]?
    var remoteURL: NSURL?
    
    func sync(completion: ThrowConfigWithInnerBlock? = nil) {
        
    }
    
}