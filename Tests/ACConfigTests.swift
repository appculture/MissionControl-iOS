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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
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
    
    let localConfig: [String : AnyObject] = [
        "LocalBool" : true,
        "LocalInt" : 8,
        "LocalDouble" : 0.21,
        "LocalString" : "Local"
    ]
    
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
