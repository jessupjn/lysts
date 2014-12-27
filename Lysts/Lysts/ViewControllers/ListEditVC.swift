//
//  ListEditVC.swift
//  Lysts
//
//  Created by Jack on 12/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

protocol ListEditVCDelegate {
    func dataUpdated();
}

class ListEditVC : UIViewController, UITextFieldDelegate {
    
    private
    var STRING_CREATE = "Create New List"
    var STRING_EDIT = "Edit List"
    var singleton = Singleton.getSingleton()
    var delegate:ListEditVCDelegate! = nil
    var _list : List?
    
    @IBOutlet var _lblHeader:UILabel!
    @IBOutlet var _lblTouchID:UILabel!
    @IBOutlet var _blurView:UIView!
    @IBOutlet var _secure_switch:UISwitch!
    
    @IBOutlet var _viwRoundedBg:[UIView]!
    @IBOutlet var _txfName:UITextField!
    @IBOutlet var _txfDescription:UITextField!
    @IBOutlet var _contentYConstraint:NSLayoutConstraint!

    func setListInfo(list:List?) {
        if list != nil {
            println("setListInfo: \( list!.name() )")
            _list = list!
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        self._contentYConstraint.constant = UIScreen.mainScreen().bounds.height/3 - 35
        self.view.layoutIfNeeded()

        _blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "endEditing"))
        _secure_switch.transform = CGAffineTransformMakeScale(0.65, 0.65);
        _secure_switch.superview!.layoutIfNeeded()
        println(_secure_switch.frame)
        
        let context = LAContext() // Get the local authentication context.
        var error: NSError? // Declare a NSError variable.
        if !context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            self._secure_switch.hidden = true
            var str = "Your device cannot be used "
            if UIScreen.mainScreen().bounds.width < 330 {
                str += "\n"
                _lblTouchID.textAlignment = .Center
                var center = _lblTouchID.center
                center.x = UIScreen.mainScreen().bounds.width/2
                _lblTouchID.center = center
                
            }
            str += "with TouchID"
            _lblTouchID.text = str
            _lblTouchID.numberOfLines = 2
        }
        
        for viw in _viwRoundedBg {
            viw.layer.cornerRadius = viw.frame.height / 3
        }
        
        _lblHeader.text = _list == nil ? STRING_CREATE : STRING_EDIT
        _secure_switch.setOn(false, animated: false)
        if _list != nil {
            _txfName.text = _list?.name()
            if _list!.description() != nil { _txfDescription.text = _list!.description() }
            _secure_switch.setOn(_list!.isEncrypted(), animated: false)
        }
    }
    
    @IBAction func btnActionCancel(sender:UIButton){
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion:nil)
    }

    @IBAction func btnActionDone(sender:UIButton){
        var name = _txfName.text
        var description = _txfDescription.text
        var encrypt = _secure_switch.on
        
        if countElements(name) < 1 {
            println("name not long enough")
            return
        }
        
//        if(list != nil)
        var list = singleton.getList(_list?.name()) != nil ? singleton.getList(_list?.name())! : List(name: name, description: description, encrypted: encrypt)
        
        if singleton.createOrEditList(list, new_list_obj: List(name: name, description: description, encrypted: encrypt)) {
            delegate.dataUpdated()
            self.view.endEditing(true)
            btnActionCancel(sender)
        }
        
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self._contentYConstraint.constant = 63
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func textFieldDidEndEditing(textField: UITextField) {
        self._contentYConstraint.constant = UIScreen.mainScreen().bounds.height/3 - 35
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}