//
//  ItemViewVC.swift
//  Lysts
//
//  Created by Jack on 12/17/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class ItemViewVC : UIViewController {

    override func viewWillAppear(animated: Bool) {
        var color = UIColor(red: 255.0/255, green: 170.0/255, blue: 55.0/255, alpha: 1.0)
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.navigationController!.navigationBar.barTintColor = color
        })
        self.navigationController?.navigationItem.backBarButtonItem?.title = "list"
    }
    
    @IBAction func shareItem() {
        
    }
}