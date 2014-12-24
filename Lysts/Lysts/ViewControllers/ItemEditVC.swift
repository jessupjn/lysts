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
    
    @IBOutlet var _lblHeader:UILabel!
    @IBOutlet var _blurView:UIView!
    
    @IBOutlet var _viwNameBg:UIView!
    @IBOutlet var _txfName:UITextField!
    
    override func viewDidLoad() {
//        _lblHeader.text = _name == nil ? STRING_CREATE : STRING_EDIT

    }
    
    func setItemInfo(item:ListItem) {
        println("setItemInfo: \(item.getTitle())")
        _name = item.getTitle()
    }
    
    
    @IBAction func btnActionCancel(sender:UIButton){
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func btnActionDone(sender:UIButton){

        btnActionCancel(sender)
    }
}