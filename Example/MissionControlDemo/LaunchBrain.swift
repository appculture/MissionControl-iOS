//
//  LaunchBrain.swift
//  MissionControlDemo
//
//  Created by Marko Tadic on 5/20/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

protocol LaunchDelegate: class {
    
}

class LaunchBrain {
    
    // MARK: - Properties
    
    var view: LaunchView!
    weak var delegate: LaunchDelegate?
    
    // MARK: - Init
    
    init(view: LaunchView, delegate: LaunchDelegate) {
        self.view = view
        self.delegate = delegate
    }
    
}
