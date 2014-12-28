//
//  JackAlertView.swift
//  Lysts
//
//  Created by Jackson Jessup on 12/27/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class JackAlertView : NSObject {
    
    var _ok_handler : (() -> Void)?
    
    init(ok_handler:() -> Void) {
        _ok_handler = ok_handler
        super.init()
    }
    
    class func showWithTitle(title:String!, ok_title:String!, showsCancelButton:Bool!) {
        var bounds = UIScreen.mainScreen().bounds
        var alertView = UIView(frame: CGRectMake(0, 0, bounds.width/1.5, 200))
        alertView.layer.cornerRadius = 25
        alertView.clipsToBounds = true
        alertView.tag = 999
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = JackAlertView.hexColor(0xdddddd).CGColor
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        var frame = alertView.frame;
        frame.origin.x = 0;
        backgroundView.frame = frame
        backgroundView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        alertView.addSubview(backgroundView)
        var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        vibrancyView.frame = frame
        vibrancyView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        backgroundView.contentView.addSubview(vibrancyView)
        
        // horizontal divider
        var helper = UIView(frame: CGRectMake(0, alertView.frame.height-50, alertView.frame.width, 1))
        helper.backgroundColor = JackAlertView.hexColor(0x888888)
        helper.alpha = 0.2
        vibrancyView.contentView.addSubview(helper)
        
        // vertical divider
        if showsCancelButton == true {
            helper = UIView(frame: CGRectMake(alertView.frame.width/2, alertView.frame.height-50, 1, 50))
            helper.backgroundColor = JackAlertView.hexColor(0x888888)
            helper.alpha = 0.2
            vibrancyView.contentView.addSubview(helper)

            // cancel button
            helper = UIButton.buttonWithType(.Custom) as UIView
            helper.frame = CGRectMake(0, alertView.frame.height-50, alertView.frame.width/2, 50)
            (helper as UIButton).setTitle("Cancel", forState: .Normal)
            (helper as UIButton).addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
            vibrancyView.contentView.addSubview(helper)
            
            // ok button
            helper = UIButton.buttonWithType(.Custom) as UIView
            helper.frame = CGRectMake(alertView.frame.width/2, alertView.frame.height-50, alertView.frame.width/2, 50)
            (helper as UIButton).setTitle(ok_title, forState: .Normal)
            (helper as UIButton).addTarget(self, action: "handler", forControlEvents: .TouchUpInside)
            vibrancyView.contentView.addSubview(helper)

        } else {
            helper = UIButton.buttonWithType(.Custom) as UIView
            helper.frame = CGRectMake(0, alertView.frame.height-50, alertView.frame.width, 50)
            (helper as UIButton).setTitle(ok_title, forState: .Normal)
            vibrancyView.contentView.addSubview(helper)
        }
//        var lbl = UILabel()
//        lbl.text = title
//        lbl.sizeToFit()
//        lbl.center = CGPointMake(frame.size.width/2, frame.size.height*0.75)
//        lbl.textColor = .lightGrayColor()
//        vibrancyView.addSubview(lbl)
        
        var topViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        while let tv = topViewController.presentedViewController { topViewController = tv }
        alertView.center = topViewController.view.center
        topViewController.view.addSubview(alertView)
    }
    
    func cancel(sender:UIButton) {
        var topViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        while let tv = topViewController.presentedViewController { topViewController = tv }
        topViewController.view.viewWithTag(999)?.removeFromSuperview()
    }
    
    func handler() {
        if _ok_handler != nil {
            _ok_handler!()
        }
    }
    
    private class func hexColor(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}