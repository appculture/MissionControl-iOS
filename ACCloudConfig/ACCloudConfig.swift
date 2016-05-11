//
//  ACCloudConfig.swift
//  ACCloudConfig
//
//  Created by Marko Tadic on 5/11/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation

// MARK: CloudConfig

/// Facade class for using remote settings via ACCloudConfig.
public class CloudConfig {
    
    // MARK: - Types
    
    /// Errors types which can be throwed when refreshing local settings from remote.
    public enum Error: ErrorType {
        case NoInternet
        case BadResponse
    }
    
    /// Constants for keys of sent NSNotification objects.
    public struct Notification {
        /// This notification is sent only the first time when local config is refreshed from cloud config.
        static let ConfigLoaded = "ACCloudConfig.Loaded"
        /// This notification is sent each time when local config is refreshed from cloud config.
        static let ConfigRefreshed = "ACCloudConfig.Refreshed"
        /// This notification is sent when refreshing local config from cloud config failed.
        static let ConfigRefreshFailed = "ACCloudConfig.RefreshFailed"
    }
    
    // MARK: - Properties
    
    /// Returns date of last successful refresh of local config from cloud.
    public class var lastRefreshDate: NSDate? {
        return ACCloudConfig.sharedInstance.lastRefreshDate
    }
    
    /// The latest version of settings dictionary, directly accessible, if needed.
    public class var settings: [String : AnyObject] {
        return ACCloudConfig.sharedInstance.settings ?? [String : AnyObject]()
    }
    
    // MARK: - API
    
    /**
        This should be called on your app start to initialize cloud config. 
        All parameters are optional but this is the only way you can set them.
        Best place to call this method is in your AppDelegate's `didFinishLaunchingWithOptions:`.
     
        - parameter localConfig: Default local config which can be used before refreshing from cloud config.
        - parameter localConfig: Default local config which can be used before refreshing from cloud config.
    */
    public class func launch(localConfig localConfig: [String : AnyObject]? = nil, remoteConfigURL url: NSURL? = nil) {
        ACCloudConfig.sharedInstance.settings = localConfig
        ACCloudConfig.sharedInstance.remoteURL = url
    }
    
    /**
        Manually initiates refreshing of local config from cloud config if needed.
        This is also automatically called on `UIApplicationDidBecomeActiveNotification`.
     
        - parameter completion: Completion handler (SEE: `ThrowConfigWithInnerBlock`).
    */
    public class func refresh(completion: ThrowConfigWithInnerBlock? = nil) {
        ACCloudConfig.sharedInstance.refresh(completion)
    }
    
}

// MARK: Custom Types

/// Block which throws received cloud config inside inner block.
public typealias ThrowConfigWithInnerBlock = (config: () throws -> [String : AnyObject]) -> Void

// MARK: Accessors

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.
    
    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.
 
    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudInt(key: String, _ defaultValue: Int) -> Int {
    return defaultValue
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudDouble(key: String, _ defaultValue: Double) -> Double {
    return defaultValue
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudBool(key: String, _ defaultValue: Bool) -> Bool {
    return defaultValue
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudString(key: String, _ defaultValue: String) -> String {
    return defaultValue
}

// MARK: ACCloudConfig

private class ACCloudConfig {
    
    static let sharedInstance = ACCloudConfig()
    
    var lastRefreshDate: NSDate?
    var settings: [String : AnyObject]?
    var remoteURL: NSURL?
    
    func refresh(completion: ThrowConfigWithInnerBlock? = nil) {
        
    }
    
}