//
// Brain.swift
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

/// Block which throws via inner block.
public typealias ThrowWithInnerBlock = (() throws -> Void) -> Void

/// Block which throws dictionary via inner block.
public typealias ThrowJSONWithInnerBlock = (_ block: @escaping () throws -> [String : AnyObject]) -> Void

class ACMissionControl {
    
    // MARK: - Singleton
    
    static let shared = ACMissionControl()
    
    // MARK: - Properties
    
    weak var delegate: MissionControlDelegate?
    
    var localConfig: [String : Any]?
    
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
    
    var remoteConfig: [String : Any]? {
        didSet {
            if let newConfig = remoteConfig {
                refreshDate = Date()
                
                cachedConfig = newConfig
                cacheDate = refreshDate
                
                informListeners(oldConfig: oldValue, newConfig: newConfig)
            }
        }
    }
    
    private func informListeners(oldConfig: [String : Any]?, newConfig: [String : Any]) {
        let userInfo = userInfoWithConfig(old: oldConfig, new: newConfig)
        delegate?.missionControlDidRefreshConfig(old: oldConfig, new: newConfig)
        sendNotification(MissionControl.Notification.DidRefreshConfig, userInfo: userInfo)
    }
    
    var refreshDate: Date?
    
    private struct Cache {
        static let Config = "ACMissionControl.CachedConfig"
        static let Date = "ACMissionControl.CacheDate"
    }
    
    var cachedConfig: [String : Any]? {
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
    
    // MARK: - API
    
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
    
    private func informListeners(_ error: Error) {
        delegate?.missionControlDidFailRefreshingConfig(error: error)
        let userInfo: [AnyHashable : Any] = ["Error" : "\(error)"]
        sendNotification(MissionControl.Notification.DidFailRefreshingConfig, userInfo: userInfo)
    }
    
    // MARK: - Helpers
    
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
    
    private func userInfoWithConfig(old: [AnyHashable : Any]?, new: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        if old == nil && new == nil {
            return nil
        } else {
            var userInfo = [AnyHashable : Any]()
            if let oldConfig = old {
                userInfo[MissionControl.Notification.UserInfo.OldConfigKey] = oldConfig
            }
            if let newConfig = new {
                userInfo[MissionControl.Notification.UserInfo.NewConfigKey] = newConfig
            }
            return userInfo
        }
    }
    
    private func sendNotification(_ name: String, userInfo: [AnyHashable : Any]? = nil) {
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: name), object: self, userInfo: userInfo)
    }
    
    private func getRemoteConfig(_ completion: @escaping ThrowJSONWithInnerBlock) {
        guard let url = remoteURL
            else { completion({ throw MissionControl.ServerError.noRemoteURL }); return }
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { [unowned self] (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
                else { completion({ throw MissionControl.ServerError.badResponseCode }); return }
            self.parseRemoteConfigFromData(data, completion: completion)
        }
        
        task.resume()
    }
    
    private func parseRemoteConfigFromData(_ data: Data?, completion: ThrowJSONWithInnerBlock) {
        guard let configData = data
            else { completion({ throw MissionControl.ServerError.invalidData }); return }
        
        do {
            let json = try JSONSerialization.jsonObject(with: configData, options: .allowFragments)
            guard let config = json as? [String : AnyObject]
                else { completion({ throw MissionControl.ServerError.invalidData }); return }
            completion({ return config })
        } catch {
            completion({ throw MissionControl.ServerError.invalidData })
        }
    }
    
}
