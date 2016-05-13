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
    
    func testAccessorsWithoutDefaultValues() {
        let bool = ConfigBool("BoolKey")
        XCTAssertEqual(bool, false)
        
        let int = ConfigInt("IntKey")
        XCTAssertEqual(int, 0)
        
        let double = ConfigDouble("DoubleKey")
        XCTAssertEqual(double, 0.0)
        
        let string = ConfigString("StringKey")
        XCTAssertEqual(string, String())
    }
    
    func testAccessorsWithDefaultValues() {
        let bool = ConfigBool("BoolKey", true)
        XCTAssertEqual(bool, true)
        
        let int = ConfigInt("IntKey", 21)
        XCTAssertEqual(int, 21)
        
        let double = ConfigDouble("DoubleKey", 0.8)
        XCTAssertEqual(double, 0.8)
        
        let string = ConfigString("StringKey", "Hello")
        XCTAssertEqual(string, "Hello")
    }
    
}
