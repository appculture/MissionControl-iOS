//
//  ACCloudConfig.swift
//  ACCloudConfig
//
//  Created by Marko Tadic on 5/11/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation

// MARK: - CloudConfig

/// Facade class for using cloud config for remote settings.
public class CloudConfig {
    
    // MARK: Types
    
    /// Errors types which can be throwed when refreshing local settings from remote.
    public enum Error: ErrorType {
        /// Property `remoteConfigURL` is not set on launch.
        case BadURL
        /// Server returned response code other then 200 OK.
        case BadResponseCode
        /// Server returned no data.
        case NoData
        /// Server returned data in unsupported format.
        case BadData
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
    
    // MARK: Properties
    
    /// Returns date of last successful refresh of local config from cloud.
    public class var lastRefreshDate: NSDate? {
        return ACCloudConfig.sharedInstance.lastRefreshDate
    }
    
    /// The latest version of settings dictionary, directly accessible, if needed.
    public class var settings: [String : AnyObject] {
        return ACCloudConfig.sharedInstance.settings ?? [String : AnyObject]()
    }
    
    // MARK: API
    
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
     
        - parameter completion: Completion handler (SEE: `ThrowWithInnerBlock`).
    */
    public class func refresh(completion: ThrowWithInnerBlock? = nil) {
        ACCloudConfig.sharedInstance.refresh(completion)
    }
    
}

// MARK: - Custom Types

/// Block which throws via inner block.
public typealias ThrowWithInnerBlock = (() throws -> Void) -> Void
/// Block which throws dictionary via inner block.
public typealias ThrowJSONWithInnerBlock = (json: () throws -> [String : AnyObject]) -> Void

// MARK: - Accessors

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.
    
    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.
 
    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudInt(key: String, _ defaultValue: Int) -> Int {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? Int
        else { return defaultValue }
    return value
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudDouble(key: String, _ defaultValue: Double) -> Double {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? Double
        else { return defaultValue }
    return value
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudBool(key: String, _ defaultValue: Bool) -> Bool {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? Bool
        else { return defaultValue }
    return value
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudString(key: String, _ defaultValue: String) -> String {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? String
        else { return defaultValue }
    return value
}

// MARK: - ACCloudConfig

class ACCloudConfig {
    
    // MARK: Singleton
    
    static let sharedInstance = ACCloudConfig()
    
    // MARK: Properties
    
    var remoteURL: NSURL?
    
    var settings: [String : AnyObject]? {
        didSet {
            if oldValue == nil {
                sendNotification(CloudConfig.Notification.ConfigLoaded)
            }
            sendNotification(CloudConfig.Notification.ConfigRefreshed)
        }
    }
    
    var lastRefreshDate: NSDate?
    
    // MARK: API
    
    func refresh(completion: ThrowWithInnerBlock? = nil) {
        getCloudConfig { [unowned self] (config) in
            do {
                let cloudConfig = try config()
                self.settings = cloudConfig
                completion?({ })
            } catch {
                let userInfo = ["Error" : "\(error)"]
                self.sendNotification(CloudConfig.Notification.ConfigRefreshFailed, userInfo: userInfo)
                completion?({ throw error })
            }
        }
    }
    
    // MARK: Helpers
    
    private func sendNotification(name: String, userInfo: [NSObject : AnyObject]? = nil) {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(name, object: self, userInfo: userInfo)
    }
    
    private func getCloudConfig(completion: ThrowJSONWithInnerBlock) {
        guard let url = remoteURL
            else { completion(json: { throw CloudConfig.Error.BadURL }); return }
    
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { [unowned self] (data, response, error) in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            guard statusCode == 200
                else { completion(json: { throw CloudConfig.Error.BadResponseCode }); return }
            self.parseCloudConfigFromData(data, completion: completion)
        }
        
        task.resume()
    }
    
    private func parseCloudConfigFromData(data: NSData?, completion: ThrowJSONWithInnerBlock) {
        guard let configData = data
            else { completion(json: { throw CloudConfig.Error.NoData }); return }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(configData, options: .AllowFragments)
            guard let config = json as? [String : AnyObject]
                else { completion(json: { throw CloudConfig.Error.BadData }); return }
            completion(json: { return config })
        } catch {
            completion(json: { throw error })
        }
    }
    
}
