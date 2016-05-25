//
//  AppDelegate.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/11/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import MissionControl

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let url = NSURL(string: "http://private-83024-missioncontrol5.apiary-mock.com/mission-control/launch-config")!
        MissionControl.launch(remoteConfigURL: url)
        
        return true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        MissionControl.refresh()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        MissionControl.refresh()
    }

}
