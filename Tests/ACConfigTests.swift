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
    
    // MARK: - Set up / Tear Down / Helpers
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ACConfig.sharedInstance.reset()
        
        super.tearDown()
    }
    
    let localConfig: [String : AnyObject] = [
        "LocalBool" : true,
        "LocalInt" : 8,
        "LocalDouble" : 0.21,
        "LocalString" : "Local"
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
    
    // MARK: - Test API
    
    func testLaunchWithoutParameters() {
        Config.launch()
        
        testInitialSettings()
        testInitialLastRefreshDate()
    }
    
    func testLaunchWithLocalConfig() {
        Config.launch(localConfig: localConfig)

        let settings = Config.settings
        XCTAssertEqual(settings.count, 4, "Initial settings should contain given local config.")
        
        let date = Config.lastRefreshDate
        XCTAssertNotNil(date, "Initial last refresh date should not be nil.")
        
        testAccessorsWithLocalConfigButWithoutDefaultValues()
        testAccessorsWithLocalConfigAndDefaultValues()
    }
    
    func testRefreshWithoutRemoteURL() {
        let asyncExpectation = expectationWithDescription("refresh-no-remote-url")
        
        Config.refresh { (block) in
            do {
                let _ = try block()
            } catch {
                XCTAssertEqual("\(error)", "\(Config.Error.NoRemoteURL)", "Should return NoRemoteURL error whene remoteURL is not set.")
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRefreshWithBadRemoteURL() {
        let asyncExpectation = expectationWithDescription("refresh-bad-url")
        
        let url = NSURL(string: "http://appculture.com/not-existing-config.json")
        Config.launch(remoteConfigURL: url)
        
        Config.refresh { (block) in
            do {
                let _ = try block()
            } catch {
                XCTAssertEqual("\(error)", "\(Config.Error.BadResponseCode)", "Should return BadResponseCode error when response is not 200 OK.")
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRefreshWithEmptyDataRemoteConfig() {
        let asyncExpectation = expectationWithDescription("refresh-empty-data")
        
        let url = NSURL(string: "http://private-83024-acconfig.apiary-mock.com/acconfig/empty-config")
        Config.launch(remoteConfigURL: url)
        
        Config.refresh { (block) in
            do {
                let _ = try block()
            } catch {
                XCTAssertEqual("\(error)", "\(Config.Error.InvalidData)", "Should return InvalidData error when response data is not valid JSON.")
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    // MARK: - Test Accessors
    
    func testAccessorsWithoutLocalConfigAndDefaultValues() {
        let bool = ConfigBool("BoolKey")
        XCTAssertEqual(bool, false, "Should default to false.")
        
        let int = ConfigInt("IntKey")
        XCTAssertEqual(int, 0, "Should default to 0.")
        
        let double = ConfigDouble("DoubleKey")
        XCTAssertEqual(double, 0.0, "Should default to 0.0.")
        
        let string = ConfigString("StringKey")
        XCTAssertEqual(string, String(), "Should default to empty string.")
    }
    
    func testAccessorsWithoutLocalConfigButWithDefaultValues() {
        let bool = ConfigBool("BoolKey", true)
        XCTAssertEqual(bool, true, "Should default to given value.")
        
        let int = ConfigInt("IntKey", 21)
        XCTAssertEqual(int, 21, "Should default to given value.")
        
        let double = ConfigDouble("DoubleKey", 0.8)
        XCTAssertEqual(double, 0.8, "Should default to given value.")
        
        let string = ConfigString("StringKey", "Hello")
        XCTAssertEqual(string, "Hello", "Should default to given value.")
    }
    
    func testAccessorsWithLocalConfigButWithoutDefaultValues() {
        Config.launch(localConfig: localConfig)
        
        let bool = ConfigBool("LocalBool")
        XCTAssertEqual(bool, true, "Should default to value in local config.")
        
        let int = ConfigInt("LocalInt")
        XCTAssertEqual(int, 8, "Should default to value in local config.")
        
        let double = ConfigDouble("LocalDouble")
        XCTAssertEqual(double, 0.21, "Should default to value in local config.")
        
        let string = ConfigString("LocalString")
        XCTAssertEqual(string, "Local", "Should default to value in local config.")
    }
    
    func testAccessorsWithLocalConfigAndDefaultValues() {
        Config.launch(localConfig: localConfig)
        
        let bool = ConfigBool("LocalBool", false)
        XCTAssertEqual(bool, true, "Should default to value in local config.")
        
        let int = ConfigInt("LocalInt", 123)
        XCTAssertEqual(int, 8, "Should default to value in local config.")
        
        let double = ConfigDouble("LocalDouble", 12.3)
        XCTAssertEqual(double, 0.21, "Should default to value in local config.")
        
        let string = ConfigString("LocalString", "Default")
        XCTAssertEqual(string, "Local", "Should default to value in local config.")
    }
    
}
