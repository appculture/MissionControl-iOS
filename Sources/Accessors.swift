//
// Accessors.swift
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
    if let remoteValue = ACMissionControl.shared.remoteConfig?[key] as? T {
        return remoteValue
    } else if let cachedValue = ACMissionControl.shared.cachedConfig?[key] as? T {
        return cachedValue
    } else if let localValue = ACMissionControl.shared.localConfig?[key] as? T {
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
public func ConfigGenericForce<T>(_ key: String, fallback: T, completion: @escaping ((_ forced: T) -> Void)) {
    MissionControl.refresh({ (innerBlock) in
        do {
            let _ = try innerBlock()
            completion(ConfigGeneric(key, fallback: fallback))
        } catch {
            completion(fallback)
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
public func ConfigBoolForce(_ key: String, fallback: Bool, completion: @escaping ((_ forced: Bool) -> Void)) {
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
public func ConfigIntForce(_ key: String, fallback: Int, completion: @escaping ((_ forced: Int) -> Void)) {
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
public func ConfigDoubleForce(_ key: String, fallback: Double, completion: @escaping ((_ forced: Double) -> Void)) {
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
public func ConfigStringForce(_ key: String, fallback: String, completion: @escaping ((_ forced: String) -> Void)) {
    ConfigGenericForce(key, fallback: fallback, completion: completion)
}
