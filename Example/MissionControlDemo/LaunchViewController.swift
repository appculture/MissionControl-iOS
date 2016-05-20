//
//  LaunchViewController.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/19/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, LaunchDelegate {
    
    // MARK: - Properties

    var launch: LaunchBrain!
    @IBOutlet var launchView: LaunchView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launch = LaunchBrain(view: launchView, delegate: self)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
