//
//  ItemEditVC.swift
//  Lysts
//
//  Created by Jack on 12/17/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

protocol ItemEditVCDelegate {
    func dataUpdated();
}

class ItemEditVC : UIViewController {

    private
    var STRING_CREATE = "Create New Item"
    var STRING_EDIT = "Edit Item"
    
    var singleton = Singleton.getSingleton()
    var delegate:ItemEditVCDelegate! = nil
    var _name : String?
    var _item : ListItem?

    @IBOutlet var _viwRoundedBg:[UIView]!
    
    @IBOutlet var _lblHeader:UILabel!
    @IBOutlet var _blurView:UIView!

    
    override func viewDidLoad() {
        _lblHeader.text = _item == nil ? STRING_CREATE : STRING_EDIT
        for viw in _viwRoundedBg {
            viw.layer.cornerRadius = viw.frame.height / 3
        }
        
        if _item != nil {
 
        }
    }
    
    func setItemInfo(item:ListItem) {
        println("setItemInfo: \(item.getTitle())")
        _item = item
    }
    
    
    @IBAction func btnActionCancel(sender:UIButton){
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func btnActionDone(sender:UIButton){

        btnActionCancel(sender)
    }
}