//
// MissionControl.swift
//
// Copyright (c) 2016 appculture <dev@appculture.com> http://appculture.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

// MARK: - MissionControl

/// Facade class for using MissionControl.
public class MissionControl {
    
    // MARK: Types
    
    /// Errors types which can be throwed when refreshing local config from remote.
    public enum Error: ErrorProtocol {
        /// Property `remoteConfigURL` is not set on launch.
        case noRemoteURL
        /// Server returned response code other then 200 OK.
        case badResponseCode
        /// Server returned data with invalid format.
        case invalidData
    }
    
    /// Constants for keys of sent NSNotification objects.
    public struct Notification {
        /// This notification is sent each time when config is refreshed from remote.
        public static let DidRefreshConfig = "MissionControl.DidRefreshConfig"
        /// This notification is sent when refreshing config from remote fails.
        public static let DidFailRefreshingConfig = "MissionControl.DidFailRefreshingConfig"
        
        /// Constants for keys of `userInfo` dictionary inside sent `ConfigRefreshed` NSNotification objects.
        public struct UserInfo {
            /// Previous value of `config` property (before refreshing config from remote)
            public static let OldConfigKey = "MissionControl.OldConfig"
            /// Current value of `config` property (after refreshing config from remote)
            public static let NewConfigKey = "MissionControl.NewConfig"
        }
    }
    
    // MARK: Properties
    
    /// Delegate for Mission Control.
    public class var delegate: MissionControlDelegate? {
        get { return ACMissionControl.sharedInstance.delegate }
        set { ACMissionControl.sharedInstance.delegate = newValue }
    }
    
    /// The latest version of config dictionary, directly accessible, if needed.
    public class var config: [String : AnyObject] {
        let remoteConfig = ACMissionControl.sharedInstance.remoteConfig
        let cachedConfig = ACMissionControl.sharedInstance.cachedConfig
        let localConfig = ACMissionControl.sharedInstance.localConfig
        let emptyConfig = [String : AnyObject]()
        let resolvedConfig = remoteConfig ?? cachedConfig ?? localConfig ?? emptyConfig
        return resolvedConfig
    }
    
    /// Date of last successful refresh from remote.
    public class var refreshDate: Date? {
        return ACMissionControl.sharedInstance.refreshDate
    }
    
    /// Date of last cached remote config.
    public class var cacheDate: Date? {
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
    public class func launch(localConfig: [String : AnyObject]? = nil, remoteConfigURL url: URL? = nil) {
        ACMissionControl.sharedInstance.localConfig = localConfig
        ACMissionControl.sharedInstance.remoteURL = url
    }
    
    /**
        Manually initiates refreshing of local config from remote config if needed.
        If `remoteConfigURL` is not set when this is called an error will be thrown inside inner block.
        Good place to call this is in your AppDelegate's `applicationDidBecomeActive:`.
     
        - parameter completion: Completion handler (SEE: `ThrowWithInnerBlock`).
    */
    public class func refresh(_ completion: ThrowWithInnerBlock? = nil) {
        ACMissionControl.sharedInstance.refresh(completion)
    }
    
}

// MARK: - MissionControlDelegate

/**
    Delegate for Mission Control.
 
    All NSNotification events are also sent via this delegate.
*/
public protocol MissionControlDelegate: class {
    /**
        Called each time when config is refreshed from remote.
     
        - parameter old: Previous config (nil if it's the first refresh)
        - parameter new: Current config
    */
    func missionControlDidRefreshConfig(old: [String : AnyObject]?, new: [String : AnyObject])
    
    /**
        Called when refreshing config from remote fails.
     
        - parameter error: Error which happened during config refresh from remote.
    */
    func missionControlDidFailRefreshingConfig(error: ErrorProtocol)
}

// MARK: - Custom Types

/// Block which throws via inner block.
public typealias ThrowWithInnerBlock = (() throws -> Void) -> Void

/// Block which throws dictionary via inner block.
public typealias ThrowJSONWithInnerBlock = (block: () throws -> [String : AnyObject]) -> Void

// MARK: - Accessors

/**
    Accessor for retreiving setting of generic type `T` for given key.

    This method will resolve to proper setting by following this priority order:
    1. Remote setting from memory (received in the last refresh).
    2. Remote setting from disk cache (if never refreshed in current app session (ex. offline)).
    3. Local setting from disk (defaults provided in `localConfig` on MissionControl `launch`).
    4. Provided fallback value (if provided)

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if setting is not available in any config.

    - returns: Resolved setting of generic type `T` for given key.
*/
public func ConfigGeneric<T>(_ key: String, fallback: T) -> T {
    if let remoteValue = ACMissionControl.sharedInstance.remoteConfig?[key] as? T {
        return remoteValue
    } else if let cachedValue = ACMissionControl.sharedInstance.cachedConfig?[key] as? T {
        return cachedValue
    } else if let localValue = ACMissionControl.sharedInstance.localConfig?[key] as? T {
        return localValue
    } else {
        return fallback
    }
}

/**
    Async "Force Remote" Accessor for retreiving the latest setting of generic type `T` for given key.
 
    This method will first call `refresh` method after which it will evaluate its success.
 
    If `refresh` was successful, it will call normal accessor of generic type `T` for given key,
    which will by its priority order resolve to the latest remote value as a parameter inside `completion` handler.
 
    If `refresh` fails, it will return provided `fallback` value as a parameter inside `completion` block.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value of generic type `T` if refresh is not successful.
*/
public func ConfigGenericForce<T>(_ key: String, fallback: T, completion: ((forced: T) -> Void)) {
    MissionControl.refresh({ (innerBlock) in
        do {
            let _ = try innerBlock()
            completion(forced: ConfigGeneric(key, fallback: fallback))
        } catch {
            completion(forced: fallback)
        }
    })
}

/**
    Accessor helper for retreiving setting of type `Bool` for given key.
    It will call `ConfigGeneric<T>` with `Bool` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if setting not available in any config. Defaults to `Bool()`.

    - returns: Resolved setting of type `Bool` for given key.
*/
public func ConfigBool(_ key: String, fallback: Bool = Bool()) -> Bool {
    return ConfigGeneric(key, fallback: fallback)
}

/**
    Async "Force Remote" Accessor helper for retreiving the latest setting of type `Bool` for given key.
    It will call `ConfigGenericForce<T>` with `Bool` type.
 
    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if refresh was not successful.
*/
public func ConfigBoolForce(_ key: String, fallback: Bool, completion: ((forced: Bool) -> Void)) {
    ConfigGenericForce(key, fallback: fallback, completion: completion)
}

/**
    Accessor helper for retreiving setting of type `Int` for given key.
    It will call `ConfigGeneric<T>` with `Int` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if setting not available in any config. Defaults to `Int()`.

    - returns: Resolved setting of type `Int` for given key.
*/
public func ConfigInt(_ key: String, fallback: Int = Int()) -> Int {
    return ConfigGeneric(key, fallback: fallback)
}

/**
    Async "Force Remote" Accessor helper for retreiving the latest setting of type `Int` for given key.
    It will call `ConfigGenericForce<T>` with `Int` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if refresh was not successful.
*/
public func ConfigIntForce(_ key: String, fallback: Int, completion: ((forced: Int) -> Void)) {
    ConfigGenericForce(key, fallback: fallback, completion: completion)
}

/**
    Accessor helper for retreiving setting of type `Double` for given key.
    It will call `ConfigGeneric<T>` with `Double` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if setting not available in any config. Defaults to `Double()`.

    - returns: Resolved setting of type `Double` for given key.
*/
public func ConfigDouble(_ key: String, fallback: Double = Double()) -> Double {
    return ConfigGeneric(key, fallback: fallback)
}

/**
    Async "Force Remote" Accessor helper for retreiving the latest setting of type `Double` for given key.
    It will call `ConfigGenericForce<T>` with `Double` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if refresh was not successful.
*/
public func ConfigDoubleForce(_ key: String, fallback: Double, completion: ((forced: Double) -> Void)) {
    ConfigGenericForce(key, fallback: fallback, completion: completion)
}

/**
    Accessor helper for retreiving setting of type `String` for given key.
    It will call `ConfigGeneric<T>` with `String` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if setting not available in any config. Defaults to `String()`.

    - returns: Resolved setting of type `String` for given key.
*/
public func ConfigString(_ key: String, fallback: String = String()) -> String {
    return ConfigGeneric(key, fallback: fallback)
}

/**
    Async "Force Remote" Accessor helper for retreiving the latest setting of type `String` for given key.
    It will call `ConfigGenericForce<T>` with `String` type.

    - parameter key: Key for the setting.
    - parameter fallback: Fallback value if refresh was not successful.
*/
public func ConfigStringForce(_ key: String, fallback: String, completion: ((forced: String) -> Void)) {
    ConfigGenericForce(key, fallback: fallback, completion: completion)
}

// MARK: - ACMissionControl

class ACMissionControl {
    
    // MARK: Singleton
    
    static let sharedInstance = ACMissionControl()
    
    // MARK: Properties
    
    weak var delegate: MissionControlDelegate?
    
    var localConfig: [String : AnyObject]?
    
    var remoteURL: URL? {
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
                refreshDate = Date()
                
                cachedConfig = newConfig
                cacheDate = refreshDate

                informListeners(oldConfig: oldValue, newConfig: newConfig)
            }
        }
    }
    
    private func informListeners(oldConfig: [String : AnyObject]?, newConfig: [String : AnyObject]) {
        let userInfo = userInfoWithConfig(old: oldConfig, new: newConfig)
        delegate?.missionControlDidRefreshConfig(old: oldConfig, new: newConfig)
        sendNotification(MissionControl.Notification.DidRefreshConfig, userInfo: userInfo)
    }
    
    var refreshDate: Date?
    
    private struct Cache {
        static let Config = "ACMissionControl.CachedConfig"
        static let Date = "ACMissionControl.CacheDate"
    }
    
    var cachedConfig: [String : AnyObject]? {
        get {
            let userDefaults = UserDefaults.standard
            let config = userDefaults.object(forKey: Cache.Config) as? [String : AnyObject]
            return config
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: Cache.Config)
            userDefaults.synchronize()
        }
    }
    
    var cacheDate: Date? {
        get {
            let userDefaults = UserDefaults.standard
            let config = userDefaults.object(forKey: Cache.Date) as? Date
            return config
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: Cache.Date)
            userDefaults.synchronize()
        }
    }
    
    // MARK: API
    
    func refresh(_ completion: ThrowWithInnerBlock? = nil) {
        getRemoteConfig { [unowned self] (block) in
            DispatchQueue.main.async { [unowned self] in
                do {
                    let remoteConfig = try block()
                    self.remoteConfig = remoteConfig
                    completion?({ })
                } catch {
                    self.informListeners(error)
                    completion?({ throw error })
                }
            }
        }
    }
    
    private func informListeners(_ error: ErrorProtocol) {
        delegate?.missionControlDidFailRefreshingConfig(error: error)
        let userInfo = ["Error" : "\(error)"]
        sendNotification(MissionControl.Notification.DidFailRefreshingConfig, userInfo: userInfo)
    }
    
    // MARK: Helpers
    
    func resetAll() {
        localConfig = nil
        cachedConfig = nil
        remoteConfig = nil
        refreshDate = nil
        remoteURL = nil
        delegate = nil
    }
    
    func resetRemote() {
        remoteConfig = nil
        refreshDate = nil
    }
    
    private func userInfoWithConfig(old: [String : AnyObject]?, new: [String : AnyObject]?) -> [NSObject : AnyObject]? {
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
    
    private func sendNotification(_ name: String, userInfo: [NSObject : AnyObject]? = nil) {
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: name), object: self, userInfo: userInfo)
    }
    
    private func getRemoteConfig(_ completion: ThrowJSONWithInnerBlock) {
        guard let url = remoteURL
            else { completion(block: { throw MissionControl.Error.noRemoteURL }); return }
    
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { [unowned self] (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse where httpResponse.statusCode == 200
            else { completion(block: { throw MissionControl.Error.badResponseCode }); return }
            self.parseRemoteConfigFromData(data, completion: completion)
        }
        
        task.resume()
    }
    
    private func parseRemoteConfigFromData(_ data: Data?, completion: ThrowJSONWithInnerBlock) {
        guard let configData = data
            else { completion(block: { throw MissionControl.Error.invalidData }); return }
        
        do {
            let json = try JSONSerialization.jsonObject(with: configData, options: .allowFragments)
            guard let config = json as? [String : AnyObject]
                else { completion(block: { throw MissionControl.Error.invalidData }); return }
            completion(block: { return config })
        } catch {
            completion(block: { throw MissionControl.Error.invalidData })
        }
    }
    
}
