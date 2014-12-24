//
//  ListEditVC.swift
//  Lysts
//
//  Created by Jack on 12/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

protocol ListEditVCDelegate {
    func dataUpdated();
}

class ListEditVC : UIViewController {
    
    private
    var STRING_CREATE = "Create New List"
    var STRING_EDIT = "Edit List"
    var singleton = Singleton.getSingleton()
    var delegate:ListEditVCDelegate! = nil
    var _name : String?
    
    @IBOutlet var _lblHeader:UILabel!
    @IBOutlet var _blurView:UIView!
    
    @IBOutlet var _viwNameBg:UIView!
    @IBOutlet var _txfName:UITextField!

    func setListInfo(name:String) {
        println("setListInfo: \(name)")
        if( name != "") {
            _name = name
        }
    }
    
    override func viewDidLoad() {

        _blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "endEditing"))

        _viwNameBg.layer.cornerRadius = _viwNameBg.frame.height / 3

        _lblHeader.text = _name == nil ? STRING_CREATE : STRING_EDIT
        if _name != nil { _txfName.text = _name }
        
    }
    
    func endEditing() {
        _blurView.superview!.endEditing(true)
    }
    
    @IBAction func btnActionCancel(sender:UIButton){
        dismissViewControllerAnimated(true, completion:nil)
    }

    @IBAction func btnActionDone(sender:UIButton){
        var name = _txfName.text
        if countElements(name) < 1 {
            println("name not long enough")
            return
        }
        
        var list = singleton.getList(_name) != nil ? singleton.getList(_name)! : List(name: name)
        
        if singleton.createOrEditList(list, name: name) {
            
            delegate.dataUpdated()
            endEditing()
            btnActionCancel(sender)
        }
        
    }
}