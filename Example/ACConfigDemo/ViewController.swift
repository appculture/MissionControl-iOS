//
//  ViewController.swift
//  ACCloudConfig
//
//  Created by Marko Tadic on 5/11/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import ACConfig

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testWithoutDefaultValues()
        testWithDefaultValues()
    }
    
    func testWithoutDefaultValues() {
        let bool = ConfigBool("BoolKey")
        print("bool: \(bool)")
        
        let int = ConfigInt("IntKey")
        print("int: \(int)")
        
        let double = ConfigDouble("DoubleKey")
        print("double: \(double)")
        
        let string = ConfigString("StringKey")
        print("string: \(string)")
    }
    
    func testWithDefaultValues() {
        let bool = ConfigBool("BoolKey", true)
        print("bool: \(bool)")
        
        let int = ConfigInt("IntKey", 21)
        print("int: \(int)")
        
        let double = ConfigDouble("DoubleKey", 0.8)
        print("double: \(double)")
        
        let string = ConfigString("StringKey", "Hello")
        print("string: \(string)")
    }

}

