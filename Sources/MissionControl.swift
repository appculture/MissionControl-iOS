//
//  MissionControl.swift
//  MissionControl
//
//  Created by Marko Tadic on 5/11/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation

// MARK: - MissionControl

/// Facade class for using MissionControl.
public class MissionControl {
    
    // MARK: Types
    
    /// Errors types which can be throwed when refreshing local config from remote.
    public enum Error: ErrorType {
        /// Property `remoteConfigURL` is not set on launch.
        case NoRemoteURL
        /// Server returned response code other then 200 OK.
        case BadResponseCode
        /// Server returned data with invalid format.
        case InvalidData
    }
    
    /// Constants for keys of sent NSNotification objects.
    public struct Notification {
        /// This notification is sent only the first time when local config is refreshed from remote config.
        public static let ConfigLoaded = "MissionControl.ConfigLoaded"
        /// This notification is sent each time when local config is refreshed from remote config.
        public static let ConfigRefreshed = "MissionControl.ConfigRefreshed"
        /// This notification is sent when refreshing local config from remote config failed.
        public static let ConfigRefreshFailed = "MissionControl.ConfigRefreshFailed"
        
        /// Constants for keys of `userInfo` dictionary of sent NSNotification objects.
        public struct UserInfo {
            /// Previous value of `config` property (before refreshing config from remote)
            public static let OldConfigKey = "MissionControl.OldConfig"
            /// Current value of `config` property (after refreshing config from remote)
            public static let NewConfigKey = "MissionControl.NewConfig"
        }
    }
    
    // MARK: Properties
    
    /// The latest version of config dictionary, directly accessible, if needed.
    public class var config: [String : AnyObject] {
        let remoteConfig = ACMissionControl.sharedInstance.remoteConfig
        let cachedConfig = ACMissionControl.sharedInstance.cachedConfig
        let localConfig = ACMissionControl.sharedInstance.localConfig
        let emptyConfig = [String : AnyObject]()
        let relevantConfig = remoteConfig ?? cachedConfig ?? localConfig ?? emptyConfig
        return relevantConfig
    }
    
    /// Date of last successful refresh from remote.
    public class var refreshDate: NSDate? {
        return ACMissionControl.sharedInstance.refreshDate
    }
    
    /// Date of last cached remote config.
    public class var cacheDate: NSDate? {
        return ACMissionControl.sharedInstance.cacheDate
    }
    
    // MARK: API
    
    /**
        This should be called on your app start to initialize and/or refresh remote config.
        All parameters are optional but this is the only way you can set them.
        Good place to call this is in your AppDelegate's `didFinishLaunchingWithOptions:`.
     
        - parameter localConfig: Default local config which can be used until remote config is fetched.
        - parameter remoteConfigURL: If this parameter is set then `refresh` will be called, otherwise not.
    */
    public class func launch(localConfig localConfig: [String : AnyObject]? = nil, remoteConfigURL url: NSURL? = nil) {
        ACMissionControl.sharedInstance.localConfig = localConfig
        ACMissionControl.sharedInstance.remoteURL = url
    }
    
    /**
        Manually initiates refreshing of local config from remote config if needed.
        If `remoteConfigURL` is not set when this is called an error will be thrown inside inner block.
        Good place to call this is in your AppDelegate's `applicationDidBecomeActive:`.
     
        - parameter completion: Completion handler (SEE: `ThrowWithInnerBlock`).
    */
    public class func refresh(completion: ThrowWithInnerBlock? = nil) {
        ACMissionControl.sharedInstance.refresh(completion)
    }
    
}

// MARK: - Custom Types

/// Block which throws via inner block.
public typealias ThrowWithInnerBlock = (() throws -> Void) -> Void

/// Block which throws dictionary via inner block.
public typealias ThrowJSONWithInnerBlock = (block: () throws -> [String : AnyObject]) -> Void

// MARK: - Accessors

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of remote config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to false.

    - returns: Latest cached value for given key, or provided default value if remote config is not available.
*/
public func ConfigBool(key: String, _ defaultValue: Bool = false) -> Bool {
    if let remoteValue = ACMissionControl.sharedInstance.remoteConfig?[key] as? Bool {
        return remoteValue
    } else if let cachedValue = ACMissionControl.sharedInstance.cachedConfig?[key] as? Bool {
        return cachedValue
    } else if let localValue = ACMissionControl.sharedInstance.localConfig?[key] as? Bool {
        return localValue
    } else {
        return defaultValue
    }
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of remote config.
    
    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to 0.
 
    - returns: Latest cached value for given key, or provided default value if remote config is not available.
*/
public func ConfigInt(key: String, _ defaultValue: Int = 0) -> Int {
    if let remoteValue = ACMissionControl.sharedInstance.remoteConfig?[key] as? Int {
        return remoteValue
    } else if let cachedValue = ACMissionControl.sharedInstance.cachedConfig?[key] as? Int {
        return cachedValue
    } else if let localValue = ACMissionControl.sharedInstance.localConfig?[key] as? Int {
        return localValue
    } else {
        return defaultValue
    }
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of remote config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to 0.0.

    - returns: Latest cached value for given key, or provided default value if remote config is not available.
*/
public func ConfigDouble(key: String, _ defaultValue: Double = 0.0) -> Double {
    if let remoteValue = ACMissionControl.sharedInstance.remoteConfig?[key] as? Double {
        return remoteValue
    } else if let cachedValue = ACMissionControl.sharedInstance.cachedConfig?[key] as? Double {
        return cachedValue
    } else if let localValue = ACMissionControl.sharedInstance.localConfig?[key] as? Double {
        return localValue
    } else {
        return defaultValue
    }
}

/**
    Accessor for retreiving the setting of `Int` type from the latest cache of remote config.

    - parameter key: Key for the setting.
    - parameter defaultValue: Default value for the setting. Defaults to "".

    - returns: Latest cached value for given key, or provided default value if remote config is not available.
*/
public func ConfigString(key: String, _ defaultValue: String = String()) -> String {
    if let remoteValue = ACMissionControl.sharedInstance.remoteConfig?[key] as? String {
        return remoteValue
    } else if let cachedValue = ACMissionControl.sharedInstance.cachedConfig?[key] as? String {
        return cachedValue
    } else if let localValue = ACMissionControl.sharedInstance.localConfig?[key] as? String {
        return localValue
    } else {
        return defaultValue
    }
}

// MARK: - ACMissionControl

class ACMissionControl {
    
    // MARK: Singleton
    
    static let sharedInstance = ACMissionControl()
    
    // MARK: Properties
    
    var localConfig: [String : AnyObject]?
    
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
    
    var remoteConfig: [String : AnyObject]? {
        didSet {
            if let newConfig = remoteConfig {
                refreshDate = NSDate()
                
                cachedConfig = newConfig
                cacheDate = refreshDate
                
                let userInfo = userInfoWithConfig(old: oldValue, new: newConfig)
                if oldValue == nil {
                    sendNotification(MissionControl.Notification.ConfigLoaded, userInfo: userInfo)
                }
                sendNotification(MissionControl.Notification.ConfigRefreshed, userInfo: userInfo)
            }
        }
    }
    
    var refreshDate: NSDate?
    
    private struct Cache {
        static let Config = "ACMissionControl.CachedConfig"
        static let Date = "ACMissionControl.CacheDate"
    }
    
    var cachedConfig: [String : AnyObject]? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let config = userDefaults.objectForKey(Cache.Config) as? [String : AnyObject]
            return config
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: Cache.Config)
            userDefaults.synchronize()
        }
    }
    
    var cacheDate: NSDate? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let config = userDefaults.objectForKey(Cache.Date) as? NSDate
            return config
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: Cache.Date)
            userDefaults.synchronize()
        }
    }
    
    // MARK: API
    
    func refresh(completion: ThrowWithInnerBlock? = nil) {
        getRemoteConfig { [unowned self] (block) in
            do {
                let remoteConfig = try block()
                self.remoteConfig = remoteConfig
                completion?({ })
            } catch {
                let userInfo = ["Error" : "\(error)"]
                self.sendNotification(MissionControl.Notification.ConfigRefreshFailed, userInfo: userInfo)
                completion?({ throw error })
            }
        }
    }
    
    // MARK: Helpers
    
    func resetAll() {
        localConfig = nil
        cachedConfig = nil
        remoteConfig = nil
        refreshDate = nil
        remoteURL = nil
    }
    
    func resetRemote() {
        remoteConfig = nil
        refreshDate = nil
    }
    
    private func userInfoWithConfig(old old: [String : AnyObject]?, new: [String : AnyObject]?) -> [NSObject : AnyObject]? {
        if old == nil && new == nil {
            return nil
        } else {
            var userInfo = [NSObject : AnyObject]()
            if let oldConfig = old {
                userInfo[MissionControl.Notification.UserInfo.OldConfigKey] = oldConfig
            }
            if let newConfig = new {
                userInfo[MissionControl.Notification.UserInfo.NewConfigKey] = newConfig
            }
            return userInfo
        }
    }
    
    private func sendNotification(name: String, userInfo: [NSObject : AnyObject]? = nil) {
        dispatch_async(dispatch_get_main_queue()) { 
            let center = NSNotificationCenter.defaultCenter()
            center.postNotificationName(name, object: self, userInfo: userInfo)
        }
    }
    
    private func getRemoteConfig(completion: ThrowJSONWithInnerBlock) {
        guard let url = remoteURL
            else { completion(block: { throw MissionControl.Error.NoRemoteURL }); return }
    
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { [unowned self] (data, response, error) in
            guard let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200
            else { completion(block: { throw MissionControl.Error.BadResponseCode }); return }
            self.parseRemoteConfigFromData(data, completion: completion)
        }
        
        task.resume()
    }
    
    private func parseRemoteConfigFromData(data: NSData?, completion: ThrowJSONWithInnerBlock) {
        guard let configData = data
            else { completion(block: { throw MissionControl.Error.InvalidData }); return }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(configData, options: .AllowFragments)
            guard let config = json as? [String : AnyObject]
                else { completion(block: { throw MissionControl.Error.InvalidData }); return }
            completion(block: { return config })
        } catch {
            completion(block: { throw MissionControl.Error.InvalidData })
        }
    }
    
}
