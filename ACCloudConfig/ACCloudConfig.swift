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
        case BadRemoteURL
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
        
        /// Constants for keys of `userInfo` dictionary of sent NSNotification objects.
        struct UserInfo {
            /// Previous value of `settings` property (before refreshing config from cloud)
            static let OldSettingsKey = "ACCloudConfig.Old"
            /// Current value of `settings` property (after refreshing config from cloud)
            static let NewSettingsKey = "ACCloudConfig.New"
        }
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
        This should be called on your app start to initialize and/or refresh cloud config.
        All parameters are optional but this is the only way you can set them.
        Good place to call this is in your AppDelegate's `didFinishLaunchingWithOptions:`.
     
        - parameter localConfig: Default local config which can be used until remote config is fetched.
        - parameter remoteConfigURL: If this parameter is set then `refresh` will be called, otherwise not.
    */
    public class func launch(localConfig localConfig: [String : AnyObject]? = nil, remoteConfigURL url: NSURL? = nil) {
        ACCloudConfig.sharedInstance.settings = localConfig
        ACCloudConfig.sharedInstance.remoteURL = url
    }
    
    /**
        Manually initiates refreshing of local config from cloud config if needed.
        If `remoteConfigURL` is not set when this is called an error will be thrown inside inner block.
        Good place to call this is in your AppDelegate's `applicationDidBecomeActive:`.
     
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
public typealias ThrowJSONWithInnerBlock = (block: () throws -> [String : AnyObject]) -> Void

// MARK: - Accessors

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.
    
    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to 0.
 
    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudInt(key: String, _ defaultValue: Int = 0) -> Int {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? Int
        else { return defaultValue }
    return value
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to 0.0.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudDouble(key: String, _ defaultValue: Double = 0.0) -> Double {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? Double
        else { return defaultValue }
    return value
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to false.

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudBool(key: String, _ defaultValue: Bool = false) -> Bool {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? Bool
        else { return defaultValue }
    return value
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of cloud config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to "".

    - returns: Latest cached value for given key, or provided default value if cloud config is not available.
*/
public func CloudString(key: String, _ defaultValue: String = String()) -> String {
    guard let value = ACCloudConfig.sharedInstance.settings?[key] as? String
        else { return defaultValue }
    return value
}

// MARK: - ACCloudConfig

class ACCloudConfig {
    
    // MARK: Singleton
    
    static let sharedInstance = ACCloudConfig()
    
    // MARK: Properties
    
    var settings: [String : AnyObject]? {
        didSet {
            if let newSetings = settings {
                let userInfo = userInfoWithSettings(old: oldValue, new: newSetings)
                if oldValue == nil {
                    sendNotification(CloudConfig.Notification.ConfigLoaded, userInfo: userInfo)
                }
                sendNotification(CloudConfig.Notification.ConfigRefreshed, userInfo: userInfo)
                lastRefreshDate = NSDate()
            }
        }
    }
    
    var remoteURL: NSURL? {
        didSet {
            if let _ = remoteURL {
                refresh({ (block) in
                    do {
                        _ = try block()
                    } catch {
                        print(error)
                    }
                })
            }
        }
    }
    
    var lastRefreshDate: NSDate?
    
    // MARK: API
    
    func refresh(completion: ThrowWithInnerBlock? = nil) {
        getCloudConfig { [unowned self] (block) in
            do {
                let cloudConfig = try block()
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
    
    private func userInfoWithSettings(old old: [String : AnyObject]?, new: [String : AnyObject]?) -> [NSObject : AnyObject]? {
        if old == nil && new == nil {
            return nil
        } else {
            var userInfo = [NSObject : AnyObject]()
            if let oldSettings = old {
                userInfo[CloudConfig.Notification.UserInfo.OldSettingsKey] = oldSettings
            }
            if let newSettings = new {
                userInfo[CloudConfig.Notification.UserInfo.NewSettingsKey] = newSettings
            }
            return userInfo
        }
    }
    
    private func sendNotification(name: String, userInfo: [NSObject : AnyObject]? = nil) {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(name, object: self, userInfo: userInfo)
    }
    
    private func getCloudConfig(completion: ThrowJSONWithInnerBlock) {
        guard let url = remoteURL
            else { completion(block: { throw CloudConfig.Error.BadRemoteURL }); return }
    
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { [unowned self] (data, response, error) in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            guard statusCode == 200
                else { completion(block: { throw CloudConfig.Error.BadResponseCode }); return }
            self.parseCloudConfigFromData(data, completion: completion)
        }
        
        task.resume()
    }
    
    private func parseCloudConfigFromData(data: NSData?, completion: ThrowJSONWithInnerBlock) {
        guard let configData = data
            else { completion(block: { throw CloudConfig.Error.NoData }); return }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(configData, options: .AllowFragments)
            guard let config = json as? [String : AnyObject]
                else { completion(block: { throw CloudConfig.Error.BadData }); return }
            completion(block: { return config })
        } catch {
            completion(block: { throw error })
        }
    }
    
}
