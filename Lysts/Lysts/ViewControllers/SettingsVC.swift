//
//  SettingsVC.swift
//  Lysts
//
//  Created by Jack on 12/17/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC : UITableViewController {
    var singleton = Singleton.getSingleton()
    
    override func viewDidLoad() {
        var color = UIColor(red: 83.0/255, green: 195.0/255, blue: 193.0/255, alpha: 1.0)
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.navigationController!.navigationBar.barTintColor = color
        })
        self.navigationItem.title = "settings"
    }
}