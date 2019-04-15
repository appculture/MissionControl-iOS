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

/// Facade class for using MissionControl.
public class MissionControl {
    
    // MARK: - Types
    
    /// Errors types which can be throwed when refreshing local config from remote.
    public enum ServerError: Error {
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
    
    // MARK: - Properties
    
    /// Delegate for Mission Control.
    public class var delegate: MissionControlDelegate? {
        get { return ACMissionControl.shared.delegate }
        set { ACMissionControl.shared.delegate = newValue }
    }
    
    /// The latest version of config dictionary, directly accessible, if needed.
    public class var config: [String : Any] {
        let remoteConfig = ACMissionControl.shared.remoteConfig
        let cachedConfig = ACMissionControl.shared.cachedConfig
        let localConfig = ACMissionControl.shared.localConfig
        let emptyConfig = [String : Any]()
        let resolvedConfig = remoteConfig ?? cachedConfig ?? localConfig ?? emptyConfig
        return resolvedConfig
    }
    
    /// Date of last successful refresh from remote.
    public class var refreshDate: Date? {
        return ACMissionControl.shared.refreshDate
    }
    
    /// Date of last cached remote config.
    public class var cacheDate: Date? {
        return ACMissionControl.shared.cacheDate
    }
    
    // MARK: - API
    
    /**
        This should be called on your app start to initialize and/or refresh remote config.
        All parameters are optional but this is the only way you can set them.
        Good place to call this is in your AppDelegate's `didFinishLaunchingWithOptions:`.
     
        - parameter localConfig: Default local config which can be used until remote config is fetched.
        - parameter remoteConfigURL: If this parameter is set then `refresh` will be called, otherwise not.
    */
    public class func launch(localConfig: [String : Any]? = nil, remoteConfigURL url: URL? = nil) {
        ACMissionControl.shared.localConfig = localConfig
        ACMissionControl.shared.remoteURL = url
    }
    
    /**
        Manually initiates refreshing of local config from remote config if needed.
        If `remoteConfigURL` is not set when this is called an error will be thrown inside inner block.
        Good place to call this is in your AppDelegate's `applicationDidBecomeActive:`.
     
        - parameter completion: Completion handler (SEE: `ThrowWithInnerBlock`).
    */
    public class func refresh(_ completion: ThrowWithInnerBlock? = nil) {
        ACMissionControl.shared.refresh(completion)
    }
    
}

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
    func missionControlDidRefreshConfig(old: [String : Any]?, new: [String : Any])
    
    /**
        Called when refreshing config from remote fails.
     
        - parameter error: Error which happened during config refresh from remote.
    */
    func missionControlDidFailRefreshingConfig(error: Error)
}
