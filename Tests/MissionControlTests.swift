//
// MissionControlTests.swift
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

import XCTest
@testable import MissionControl

class MissionControlTests: XCTestCase, MissionControlDelegate {
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ACMissionControl.shared.resetAll()
        
        super.tearDown()
    }
    
    // MARK: - Helper Properties
    
    struct URL {
        static let BadResponseConfig = Foundation.URL(string: "http://appculture.com/mission-control/not-existing-config.json")!
        static let EmptyDataConfig = Foundation.URL(string: "http://private-83024-missioncontrol5.apiary-mock.com/mission-control/empty-config")!
        static let InvalidDataConfig = Foundation.URL(string: "http://private-83024-missioncontrol5.apiary-mock.com/mission-control/invalid-config")!
        static let RemoteTestConfig = Foundation.URL(string: "http://private-83024-missioncontrol5.apiary-mock.com/mission-control/test-config")!
    }
    
    struct Key {
        static let Bool = "BoolSetting"
        static let Int = "IntSetting"
        static let Double = "DoubleSetting"
        static let String = "StringSetting"
    }
    
    let localTestConfig: [String : Any] = [
        Key.Bool : false,
        Key.Int : 21,
        Key.Double : 0.8,
        Key.String : "Local"
    ]
    
    let remoteTestConfig: [String : Any] = [
        Key.Bool : true,
        Key.Int : 8,
        Key.Double : 2.1,
        Key.String : "Remote"
    ]
    
    let fallbackTestConfig: [String : Any] = [
        Key.Bool : false,
        Key.Int : 1984,
        Key.Double : 21.08,
        Key.String : "Fallback"
    ]
    
    var didRefreshConfigExpectation: XCTestExpectation?
    var didFailRefreshingConfigExpectation: XCTestExpectation?

    // MARK: - MissionControlDelegate
    
    func missionControlDidRefreshConfig(old: [String : Any]?, new: [String : Any]) {
        didRefreshConfigExpectation?.fulfill()
    }
    
    func missionControlDidFailRefreshingConfig(error: Error) {
        didFailRefreshingConfigExpectation?.fulfill()
    }
    
    // MARK: - Test Initial State
    
    func testInitialConfig() {
        let config = MissionControl.config
        XCTAssertEqual(config.count, 0, "Initial config should be empty but not nil.")
    }
    
    func testInitialRefreshDate() {
        let date = MissionControl.refreshDate
        XCTAssertNil(date, "Initial refresh date should be nil.")
    }
    
    func testInitialAccessorsWithoutFallbackValues() {
        let bool = ConfigBool(Key.Bool)
        XCTAssertEqual(bool, false, "Should default to false.")
        
        let int = ConfigInt(Key.Int)
        XCTAssertEqual(int, 0, "Should default to 0.")
        
        let double = ConfigDouble(Key.Double)
        XCTAssertEqual(double, 0.0, "Should default to 0.0.")
        
        let string = ConfigString(Key.String)
        XCTAssertEqual(string, String(), "Should default to empty string.")
    }
    
    func testInitialAccessorsWithFallbackValues() {
        let fallbackBool = fallbackTestConfig[Key.Bool] as! Bool
        let fallbackInt = fallbackTestConfig[Key.Int] as! Int
        let fallbackDouble = fallbackTestConfig[Key.Double] as! Double
        let fallbackString = fallbackTestConfig[Key.String] as! String
        
        let bool = ConfigBool(Key.Bool, fallback: fallbackBool)
        XCTAssertEqual(bool, fallbackBool, "Should resolve to fallback value.")

        let int = ConfigInt(Key.Int, fallback: fallbackInt)
        XCTAssertEqual(int, fallbackInt, "Should resolve to fallback value.")
        
        let double = ConfigDouble(Key.Double, fallback: fallbackDouble)
        XCTAssertEqual(double, fallbackDouble, "Should resolve to fallback value.")
        
        let string = ConfigString(Key.String, fallback: fallbackString)
        XCTAssertEqual(string, fallbackString, "Should resolve to fallback value.")
    }
    
    // MARK: - Test Launch Without Parameters
    
    func testLaunchWithoutParameters() {
        MissionControl.launch()
        confirmInitialState()
    }
    
    func confirmInitialState() {
        testInitialConfig()
        testInitialRefreshDate()
        
        testInitialAccessorsWithFallbackValues()
        testInitialAccessorsWithoutFallbackValues()
    }
    
    // MARK: - Test Launch With Local Config
    
    func testLaunchWithLocalConfig() {
        MissionControl.launch(localConfig: localTestConfig)
        confirmLocalConfigState()
    }
    
    func confirmLocalConfigState() {
        let config = MissionControl.config
        XCTAssertEqual(config.count, localTestConfig.count, "Initial config should contain given local config.")
        
        let date = MissionControl.refreshDate
        XCTAssertNil(date, "Initial refresh date should be nil.")
        
        confirmLocalConfigAccessorsWithoutDefaultValues()
        confirmLocalConfigAccessorsWithDefaultValues()
    }
    
    func confirmLocalConfigAccessorsWithDefaultValues() {
        let bool = ConfigBool(Key.Bool, fallback: true)
        let expectedBool = localTestConfig[Key.Bool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should resolve to value in local test config.")
        
        let int = ConfigInt(Key.Int, fallback: 1984)
        let expectedInt = localTestConfig[Key.Int] as! Int
        XCTAssertEqual(int, expectedInt, "Should resolve to value in local test config.")
        
        let double = ConfigDouble(Key.Double, fallback: 21.08)
        let expectedDouble = localTestConfig[Key.Double] as! Double
        XCTAssertEqual(double, expectedDouble, "Should resolve to value in local test config.")
        
        let string = ConfigString(Key.String, fallback: "Default")
        let expectedString = localTestConfig[Key.String] as! String
        XCTAssertEqual(string, expectedString, "Should resolve to value in local test config.")
    }
    
    func confirmLocalConfigAccessorsWithoutDefaultValues() {
        let bool = ConfigBool(Key.Bool)
        let expectedBool = localTestConfig[Key.Bool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should resolve to value in local test config.")
        
        let int = ConfigInt(Key.Int)
        let expectedInt = localTestConfig[Key.Int] as! Int
        XCTAssertEqual(int, expectedInt, "Should resolve to value in local test config.")
        
        let double = ConfigDouble(Key.Double)
        let expectedDouble = localTestConfig[Key.Double] as! Double
        XCTAssertEqual(double, expectedDouble, "Should resolve to value in local test config.")
        
        let string = ConfigString(Key.String)
        let expectedString = localTestConfig[Key.String] as! String
        XCTAssertEqual(string, expectedString, "Should resolve to value in local test config.")
    }
    
    // MARK: - Test Launch With Remote Config
    
    func testLaunchWithRemoteConfig() {
        MissionControl.launch(remoteConfigURL: URL.RemoteTestConfig)
        confirmInitialState()
        confirmRemoteConfigStateAfterNotification(MissionControl.Notification.DidRefreshConfig)
    }
    
    // MARK: - Test Launch With Local & Remote Config
    
    func testLaunchWithLocalAndRemoteConfig() {
        MissionControl.launch(localConfig: localTestConfig, remoteConfigURL: URL.RemoteTestConfig)
        confirmLocalConfigState()
        confirmRemoteConfigStateAfterNotification(MissionControl.Notification.DidRefreshConfig)
    }
    
    // MARK: - Test Refresh
    
    func testAutomaticRefresh() {
        /// - NOTE: refresh is called automatically during launch
        MissionControl.launch(remoteConfigURL: URL.RemoteTestConfig)
        confirmRemoteConfigStateAfterNotification(MissionControl.Notification.DidRefreshConfig)
    }
    
    func testManualRefresh() {
        testAutomaticRefresh()
        
        MissionControl.refresh()
        confirmRemoteConfigStateAfterNotification(MissionControl.Notification.DidRefreshConfig)
    }
    
    // MARK: - Test Remote Accessors
    
    func confirmRemoteConfigStateAfterNotification(_ notification: String) {
        confirmDidRefreshConfigDelegateCallback()
        
        let _ = expectation(forNotification: NSNotification.Name(rawValue: notification), object: nil) { (notification) -> Bool in
            self.confirmRemoteConfigState()
            return true
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func confirmDidRefreshConfigDelegateCallback() {
        MissionControl.delegate = self
        didRefreshConfigExpectation = expectation(description: "Should call MissionControlDelegate.")
    }
    
    func confirmRemoteConfigState() {
        let config = MissionControl.config
        XCTAssertEqual(config.count, remoteTestConfig.count, "Config should contain all settings from remote config.")
        
        let date = MissionControl.refreshDate
        XCTAssertNotNil(date, "Initial refresh date should not be nil.")
        
        confirmRemoteConfigAccessorsWithDefaultValues()
        confirmRemoteConfigAccessorsWithoutDefaultValues()
    }
    
    func confirmRemoteConfigAccessorsWithDefaultValues() {
        let bool = ConfigBool(Key.Bool)
        let expectedBool = remoteTestConfig[Key.Bool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should resolve to value in remote test config.")
        
        let int = ConfigInt(Key.Int)
        let expectedInt = remoteTestConfig[Key.Int] as! Int
        XCTAssertEqual(int, expectedInt, "Should resolve to value in remote test config.")
        
        let double = ConfigDouble(Key.Double)
        let expectedDouble = remoteTestConfig[Key.Double] as! Double
        XCTAssertEqual(double, expectedDouble, "Should resolve to value in remote test config.")
        
        let string = ConfigString(Key.String)
        let expectedString = remoteTestConfig[Key.String] as! String
        XCTAssertEqual(string, expectedString, "Should resolve to value in remote test config.")
    }
    
    func confirmRemoteConfigAccessorsWithoutDefaultValues() {
        let bool = ConfigBool(Key.Bool)
        let expectedBool = remoteTestConfig[Key.Bool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should resolve to value in remote test config.")
        
        let int = ConfigInt(Key.Int)
        let expectedInt = remoteTestConfig[Key.Int] as! Int
        XCTAssertEqual(int, expectedInt, "Should resolve to value in remote test config.")
        
        let double = ConfigDouble(Key.Double)
        let expectedDouble = remoteTestConfig[Key.Double] as! Double
        XCTAssertEqual(double, expectedDouble, "Should resolve to value in remote test config.")
        
        let string = ConfigString(Key.String)
        let expectedString = remoteTestConfig[Key.String] as! String
        XCTAssertEqual(string, expectedString, "Should resolve to value in remote test config.")
    }
    
    // MARK: - Test Force Remote Accessors
    
    func testForceRemoteAccessors() {
        MissionControl.launch(remoteConfigURL: URL.RemoteTestConfig)
        
        let boolExpectation = expectation(description: "ConfigBoolForce")
        let intExpectation = expectation(description: "ConfigIntForce")
        let doubleExpectation = expectation(description: "ConfigDoubleForce")
        let stringExpectation = expectation(description: "ConfigStringForce")
        
        let fallbackBool = fallbackTestConfig[Key.Bool] as! Bool
        let fallbackInt = fallbackTestConfig[Key.Int] as! Int
        let fallbackDouble = fallbackTestConfig[Key.Double] as! Double
        let fallbackString = fallbackTestConfig[Key.String] as! String
        
        ConfigBoolForce(Key.Bool, fallback: fallbackBool) { (forced) in
            let expectedBool = self.remoteTestConfig[Key.Bool] as! Bool
            XCTAssertEqual(forced, expectedBool, "Should resolve to value in remote test config.")
            boolExpectation.fulfill()
        }
        ConfigIntForce(Key.Int, fallback: fallbackInt) { (forced) in
            let expectedInt = self.remoteTestConfig[Key.Int] as! Int
            XCTAssertEqual(forced, expectedInt, "Should resolve to value in remote test config.")
            intExpectation.fulfill()
        }
        ConfigDoubleForce(Key.Double, fallback: fallbackDouble) { (forced) in
            let expectedDouble = self.remoteTestConfig[Key.Double] as! Double
            XCTAssertEqual(forced, expectedDouble, "Should resolve to value in remote test config.")
            doubleExpectation.fulfill()
        }
        ConfigStringForce(Key.String, fallback: fallbackString) { (forced) in
            let expectedString = self.remoteTestConfig[Key.String] as! String
            XCTAssertEqual(forced, expectedString, "Should resolve to value in remote test config.")
            stringExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testForceRemoteAccessorsFallback() {
        MissionControl.launch(remoteConfigURL: URL.BadResponseConfig)
        
        let boolExpectation = expectation(description: "ConfigBoolForceFallback")
        let intExpectation = expectation(description: "ConfigIntForceFallback")
        let doubleExpectation = expectation(description: "ConfigDoubleForceFallback")
        let stringExpectation = expectation(description: "ConfigStringForceFallback")
        
        let fallbackBool = fallbackTestConfig[Key.Bool] as! Bool
        let fallbackInt = fallbackTestConfig[Key.Int] as! Int
        let fallbackDouble = fallbackTestConfig[Key.Double] as! Double
        let fallbackString = fallbackTestConfig[Key.String] as! String
        
        ConfigBoolForce(Key.Bool, fallback: fallbackBool) { (forced) in
            XCTAssertEqual(forced, fallbackBool, "Should resolve to fallback value.")
            boolExpectation.fulfill()
        }
        ConfigIntForce(Key.Int, fallback: fallbackInt) { (forced) in
            XCTAssertEqual(forced, fallbackInt, "Should resolve to fallback value.")
            intExpectation.fulfill()
        }
        ConfigDoubleForce(Key.Double, fallback: fallbackDouble) { (forced) in
            XCTAssertEqual(forced, fallbackDouble, "Should resolve to fallback value.")
            doubleExpectation.fulfill()
        }
        ConfigStringForce(Key.String, fallback: fallbackString) { (forced) in
            XCTAssertEqual(forced, fallbackString, "Should resolve to fallback value.")
            stringExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    // MARK: - Test Cache
    
    func testCache() {
        MissionControl.launch(remoteConfigURL: URL.RemoteTestConfig)
        
        let notification = MissionControl.Notification.DidRefreshConfig
        let _ = expectation(forNotification: NSNotification.Name(rawValue: notification), object: nil) { (notification) -> Bool in
            ACMissionControl.shared.resetRemote()
            self.confirmCachedConfigState()
            return true
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func confirmCachedConfigState() {
        let config = MissionControl.config
        XCTAssertEqual(config.count, remoteTestConfig.count, "Cached config should contain all settings from Remote config.")
        
        let date = MissionControl.cacheDate
        XCTAssertNotNil(date, "Cache date should not be nil.")
        
        confirmRemoteConfigAccessorsWithDefaultValues()
        confirmRemoteConfigAccessorsWithoutDefaultValues()
    }
    
    // MARK: - Test Refresh Errors
    
    func testRefreshErrorNoRemoteURL() {
        MissionControl.launch()
        
        /// - NOTE: refresh is NOT called automatically during launch (remote URL missing)
        let asyncExpectation = expectation(description: "ManualRefreshWithoutURL")
        MissionControl.refresh { (block) in
            do {
                let _ = try block()
                XCTAssert(false, "Should fall through to catch block!")
                asyncExpectation.fulfill()
            } catch {
                let message = "Should return NoRemoteURL error whene remoteURL is not set."
                XCTAssertEqual("\(error)", "\(MissionControl.ServerError.noRemoteURL)", message)
                asyncExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRefreshErrorBadResponseCode() {
        MissionControl.launch(remoteConfigURL: URL.BadResponseConfig)
        /// - NOTE: refresh is called automatically during launch
        
        let message = "Should return BadResponseCode error when response is not 200 OK."
        confirmConfigRefreshFailedNotification(MissionControl.ServerError.badResponseCode, message: message)
    }
    
    func testRefreshErrorInvalidDataEmpty() {
        MissionControl.launch(remoteConfigURL: URL.EmptyDataConfig)
        /// - NOTE: refresh is called automatically during launch
        
        let message = "Should return InvalidData error when response data is empty."
        confirmConfigRefreshFailedNotification(MissionControl.ServerError.invalidData, message: message)
    }
    
    func testRefreshErrorInvalidData() {
        MissionControl.launch(remoteConfigURL: URL.InvalidDataConfig)
        /// - NOTE: refresh is called automatically during launch
        
        let message = "Should return InvalidData error when response data is not valid JSON."
        confirmConfigRefreshFailedNotification(MissionControl.ServerError.invalidData, message: message)
    }
    
    func confirmConfigRefreshFailedNotification(_ error: Error, message: String) {
        confirmDidFailRefreshingConfigDelegateCallback()
        
        let notification = MissionControl.Notification.DidFailRefreshingConfig
        let _ = expectation(forNotification: NSNotification.Name(rawValue: notification), object: nil) { (notification) -> Bool in
            guard let errorInfo = notification.userInfo?["Error"] as? String else { return false }
            XCTAssertEqual("\(errorInfo)", "\(error)", message)
            self.confirmInitialState()
            return true
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func confirmDidFailRefreshingConfigDelegateCallback() {
        MissionControl.delegate = self
        didFailRefreshingConfigExpectation = expectation(description: "Should call MissionControlDelegate.")
    }
 
}
