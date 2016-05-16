//
//  ACConfigTests.swift
//  ACConfigTests
//
//  Created by Marko Tadic on 5/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import XCTest
@testable import ACConfig

class ACConfigTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ACConfig.sharedInstance.reset()
        
        super.tearDown()
    }
    
    // MARK: - Helper Properties
    
    struct ConfigKey {
        static let TestBool = "TestBool"
        static let TestInt = "TestInt"
        static let TestDouble = "TestDouble"
        static let TestString = "TestString"
    }
    
    let localTestConfig: [String : AnyObject] = [
        ConfigKey.TestBool : false,
        ConfigKey.TestInt : 21,
        ConfigKey.TestDouble : 0.8,
        ConfigKey.TestString : "Local"
    ]
    
    let remoteTestConfig: [String : AnyObject] = [
        ConfigKey.TestBool : true,
        ConfigKey.TestInt : 8,
        ConfigKey.TestDouble : 2.1,
        ConfigKey.TestString : "Remote"
    ]
    
    // MARK: - Test Properties
    
    func testInitialSettings() {
        let settings = Config.settings
        XCTAssertEqual(settings.count, 0, "Initial settings should be empty but not nil.")
    }
    
    func testInitialLastRefreshDate() {
        let date = Config.lastRefreshDate
        XCTAssertNil(date, "Initial last refresh date should be nil.")
    }
    
    // MARK: - Test Accessors
    
    func testInitialAccessorsWithoutDefaultValues() {
        let bool = ConfigBool(ConfigKey.TestBool)
        XCTAssertEqual(bool, false, "Should default to false.")
        
        let int = ConfigInt(ConfigKey.TestInt)
        XCTAssertEqual(int, 0, "Should default to 0.")
        
        let double = ConfigDouble(ConfigKey.TestDouble)
        XCTAssertEqual(double, 0.0, "Should default to 0.0.")
        
        let string = ConfigString(ConfigKey.TestString)
        XCTAssertEqual(string, String(), "Should default to empty string.")
    }
    
    func testInitialAccessorsWithDefaultValues() {
        let bool = ConfigBool(ConfigKey.TestBool, true)
        XCTAssertEqual(bool, true, "Should default to given value.")
        
        let int = ConfigInt(ConfigKey.TestInt, 1984)
        XCTAssertEqual(int, 1984, "Should default to given value.")
        
        let double = ConfigDouble(ConfigKey.TestDouble, 21.08)
        XCTAssertEqual(double, 21.08, "Should default to given value.")
        
        let string = ConfigString(ConfigKey.TestString, "Hello")
        XCTAssertEqual(string, "Hello", "Should default to given value.")
    }
    
    // MARK: - Test API - Launch
    
    func testLaunchWithoutParameters() {
        Config.launch()
        
        testInitialSettings()
        testInitialLastRefreshDate()
        
        testInitialAccessorsWithDefaultValues()
        testInitialAccessorsWithoutDefaultValues()
    }
    
    func testLaunchWithLocalConfig() {
        Config.launch(localConfig: localTestConfig)

        let settings = Config.settings
        XCTAssertEqual(settings.count, 4, "Initial settings should contain given local config.")
        
        let date = Config.lastRefreshDate
        XCTAssertNotNil(date, "Initial last refresh date should not be nil.")
        
        checkLocalConfigAccessorsWithoutDefaultValues()
        checkLocalConfigAccessorsWithDefaultValues()
    }
    
    func checkLocalConfigAccessorsWithDefaultValues() {
        let bool = ConfigBool(ConfigKey.TestBool, true)
        let expectedBool = localTestConfig[ConfigKey.TestBool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should default to value in local test config.")
        
        let int = ConfigInt(ConfigKey.TestInt, 1984)
        let expectedInt = localTestConfig[ConfigKey.TestInt] as! Int
        XCTAssertEqual(int, expectedInt, "Should default to value in local test config.")
        
        let double = ConfigDouble(ConfigKey.TestDouble, 21.08)
        let expectedDouble = localTestConfig[ConfigKey.TestDouble] as! Double
        XCTAssertEqual(double, expectedDouble, "Should default to value in local test config.")
        
        let string = ConfigString(ConfigKey.TestString, "Default")
        let expectedString = localTestConfig[ConfigKey.TestString] as! String
        XCTAssertEqual(string, expectedString, "Should default to value in local test config.")
    }
    
    func checkLocalConfigAccessorsWithoutDefaultValues() {
        let bool = ConfigBool(ConfigKey.TestBool)
        let expectedBool = localTestConfig[ConfigKey.TestBool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should default to value in local test config.")
        
        let int = ConfigInt(ConfigKey.TestInt)
        let expectedInt = localTestConfig[ConfigKey.TestInt] as! Int
        XCTAssertEqual(int, expectedInt, "Should default to value in local test config.")
        
        let double = ConfigDouble(ConfigKey.TestDouble)
        let expectedDouble = localTestConfig[ConfigKey.TestDouble] as! Double
        XCTAssertEqual(double, expectedDouble, "Should default to value in local test config.")
        
        let string = ConfigString(ConfigKey.TestString)
        let expectedString = localTestConfig[ConfigKey.TestString] as! String
        XCTAssertEqual(string, expectedString, "Should default to value in local test config.")
    }
    
    // MARK: - Test API - Refresh Errors
    
    func testRefreshErrorNoRemoteURL() {
        let message = "Should return NoRemoteURL error whene remoteURL is not set."
        performAsyncRefreshWithURL(nil, errorCode: Config.Error.NoRemoteURL, message: message)
    }
    
    func testRefreshErrorBadResponseCode() {
        let url = NSURL(string: "http://appculture.com/not-existing-config.json")
        let message = "Should return BadResponseCode error when response is not 200 OK."
        performAsyncRefreshWithURL(url, errorCode: Config.Error.BadResponseCode, message: message)
    }
    
    func testRefreshErrorInvalidDataEmpty() {
        let url = NSURL(string: "http://private-83024-acconfig.apiary-mock.com/acconfig/empty-config")
        let message = "Should return InvalidData error when response data is empty."
        performAsyncRefreshWithURL(url, errorCode: Config.Error.InvalidData, message: message)
    }
    
    func testRefreshErrorInvalidData() {
        let url = NSURL(string: "http://private-83024-acconfig.apiary-mock.com/acconfig/invalid-config")
        let message = "Should return InvalidData error when response data is not valid JSON."
        performAsyncRefreshWithURL(url, errorCode: Config.Error.InvalidData, message: message)
    }
    
    func performAsyncRefreshWithURL(url: NSURL?, errorCode: Config.Error, message: String) {
        let asyncExpectation = expectationWithDescription("refresh-\(url?.lastPathComponent)")
        
        if let remoteURL = url {
            Config.launch(remoteConfigURL: remoteURL)
        } else {
            Config.launch()
        }
        
        Config.refresh { (block) in
            do {
                let _ = try block()
                XCTAssert(false, "Should fail to catch block (testing errors).")
                asyncExpectation.fulfill()
            } catch {
                XCTAssertEqual("\(error)", "\(errorCode)", message)
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    // MARK: - Test API - Refresh
    
    func testRefreshWithRemoteConfig() {
        let url = NSURL(string: "http://private-83024-acconfig.apiary-mock.com/acconfig/config")!
        performAsyncRefreshWithURL(url)
    }
    
    func performAsyncRefreshWithURL(url: NSURL) {
        let asyncExpectation = expectationWithDescription("refresh-\(url.lastPathComponent)")
        
        Config.launch(remoteConfigURL: url)
        
        Config.refresh { (block) in
            do {
                let _ = try block()
                self.checkRemoteConfigAccessorsWithDefaultValues()
                self.checkRemoteConfigAccessorsWithoutDefaultValues()
                asyncExpectation.fulfill()
            } catch {
                XCTAssert(false, "Should not fail to catch block.")
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func checkRemoteConfigAccessorsWithDefaultValues() {
        let bool = ConfigBool(ConfigKey.TestBool)
        let expectedBool = remoteTestConfig[ConfigKey.TestBool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should default to value in remote test config.")
        
        let int = ConfigInt(ConfigKey.TestInt)
        let expectedInt = remoteTestConfig[ConfigKey.TestInt] as! Int
        XCTAssertEqual(int, expectedInt, "Should default to value in remote test config.")
        
        let double = ConfigDouble(ConfigKey.TestDouble)
        let expectedDouble = remoteTestConfig[ConfigKey.TestDouble] as! Double
        XCTAssertEqual(double, expectedDouble, "Should default to value in remote test config.")
        
        let string = ConfigString(ConfigKey.TestString)
        let expectedString = remoteTestConfig[ConfigKey.TestString] as! String
        XCTAssertEqual(string, expectedString, "Should default to value in remote test config.")
    }

    func checkRemoteConfigAccessorsWithoutDefaultValues() {
        let bool = ConfigBool(ConfigKey.TestBool)
        let expectedBool = remoteTestConfig[ConfigKey.TestBool] as! Bool
        XCTAssertEqual(bool, expectedBool, "Should default to value in remote test config.")
        
        let int = ConfigInt(ConfigKey.TestInt)
        let expectedInt = remoteTestConfig[ConfigKey.TestInt] as! Int
        XCTAssertEqual(int, expectedInt, "Should default to value in remote test config.")
        
        let double = ConfigDouble(ConfigKey.TestDouble)
        let expectedDouble = remoteTestConfig[ConfigKey.TestDouble] as! Double
        XCTAssertEqual(double, expectedDouble, "Should default to value in remote test config.")
        
        let string = ConfigString(ConfigKey.TestString)
        let expectedString = remoteTestConfig[ConfigKey.TestString] as! String
        XCTAssertEqual(string, expectedString, "Should default to value in remote test config.")
    }
    
}
