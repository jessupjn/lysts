//
//
//  HttpActivityAlert.swift
//
//  Created by Jackson on 12/23/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

enum HttpActivityAlertAnimationType {
    case ColorCircleCover
    case ColorCircleMutate
    case ColorSquareCover
    case ColorSquareMutate
    case CirclesPendulum
    case RotatingSquare
    case Circles
//    case ProgressBar
}

enum HttpActivityAlertPresentationType {
    case SquareNone
    case SquareAlertViewOutOfCenter
    case SquareAlertViewOutOfTop
    case RectNone
    case RectAlertViewOutOfCenter
    case RectAlertViewOutOfTop
    case NavBarNotification
    func description () -> String {
        switch self {
        case SquareNone:return "SquareNone"
        case SquareAlertViewOutOfCenter:return "SquareAlertViewOutOfCenter"
        case SquareAlertViewOutOfTop:return "SquareAlertViewOutOfTop"
        case RectNone:return "RectNone"
        case RectAlertViewOutOfCenter:return "RectAlertViewOutOfCenter"
        case RectAlertViewOutOfTop:return "RectAlertViewOutOfTop"
        case NavBarNotification:return "NavBarNotification"
        }
    }
    func shape () -> String {
        switch self {
        case SquareNone,SquareAlertViewOutOfCenter,SquareAlertViewOutOfTop: return "square"
        case RectNone,RectAlertViewOutOfCenter,RectAlertViewOutOfTop: return "rect"
        case NavBarNotification: return "bar"
        }
    }
}

@objc protocol HttpActivityAlertDelegate {
    func httpRequestSuccess(data:NSData, response:NSURLResponse)
    func httpRequestError(errorDescription:NSString)
}

class HttpActivityAlert : NSObject {
    
    /* --- properties --- */
    var animationType : HttpActivityAlertAnimationType = .ColorCircleCover
    var presentationAnimation : HttpActivityAlertPresentationType = .SquareAlertViewOutOfTop
    var title : String? = nil
    var cornerRadius : CGFloat = 20
    var animationColors:[UIColor]
    var textColor:UIColor = HttpActivityAlert.hexColor(0xdddddd)
    var httpRequest:NSURLRequest!
    var delegate:HttpActivityAlertDelegate!
    
    var backgroundStyle : UIBlurEffectStyle = .ExtraLight
    var size : CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width/3, UIScreen.mainScreen().bounds.width/3)
    
    private var animate:Bool = true
    
    /* --- public functions --- */
    override init() {
        animationColors = [HttpActivityAlert.hexColor(0xee6666), HttpActivityAlert.hexColor(0x66cccc), UIColor.yellowColor()];
        super.init()
    }
    
    init(request:NSURLRequest, delegate:HttpActivityAlertDelegate){
        self.httpRequest = request
        self.delegate = delegate
        animationColors = [HttpActivityAlert.hexColor(0xee6666), HttpActivityAlert.hexColor(0x66cccc), UIColor.yellowColor()];
        super.init()
    }
    
    func stop() {
        self.animate = false
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            for view in self.alertView.subviews {
                view.removeFromSuperview()
            }
            self.alertView.removeFromSuperview()
        })
        self.aTimer.invalidate()
    }
    
    func start() {
        self.animate = true
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          
            self.buildAlertView()
            self.buildAnimationObject()
            
            switch self.animationType {
            case .ColorSquareCover, .ColorCircleCover:
                self.aTimer = NSTimer.scheduledTimerWithTimeInterval(0.65, target: self, selector: "coverAnimation", userInfo: nil, repeats: true)
                break
            case .ColorSquareMutate, .ColorCircleMutate:
                self.aTimer = NSTimer.scheduledTimerWithTimeInterval(0.65, target: self, selector: "mutateAnimation", userInfo: nil, repeats: true)
                break
            case .RotatingSquare:
                self.aTimer = NSTimer.scheduledTimerWithTimeInterval(0.55, target: self, selector: "rotatingSquareAnimation", userInfo: nil, repeats: true)
                break
            default:
                break
            }
            
            self.presentAlert()
        })
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.beginActivity()
        }

    }
    
    
    /* --- private functions --- */
    private var alertView : UIView!
    private var vibrancyView : UIVisualEffectView!
    private func buildAlertView() {
        
        var bounds = UIScreen.mainScreen().bounds
        alertView = UIView(frame: CGRectMake(bounds.width/2, 0, 1, 1))
        alertView?.layer.cornerRadius = cornerRadius
        alertView.clipsToBounds = true
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = HttpActivityAlert.hexColor(0xdddddd).CGColor
        
        let blurEffect = UIBlurEffect(style: backgroundStyle)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        var frame = alertView.frame;
        frame.origin.x = 0;
        backgroundView.frame = frame
        backgroundView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        alertView!.addSubview(backgroundView)
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        vibrancyView.frame = frame
        vibrancyView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        backgroundView.contentView.addSubview(vibrancyView)
        
        var lbl = UILabel()
        lbl.text = title
        lbl.sizeToFit()
        lbl.center = CGPointMake(frame.size.width/2, frame.size.height*0.75)
        lbl.textColor = textColor
        vibrancyView.addSubview(lbl)
        
        var topViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        while let tv = topViewController.presentedViewController { topViewController = tv }
        alertView.center = topViewController.view.center
        topViewController.view.addSubview(alertView)
    }
    
    private func presentAlert() {
        var finalFrame : CGRect!
        var bounds = UIScreen.mainScreen().bounds
        var b = bounds.width > bounds.height ? bounds.height : bounds.width
        switch self.presentationAnimation.shape() {
        case "rect":
            finalFrame = CGRectMake(bounds.width/2-b/3, bounds.height/2-b/8, b/1.5, b/4)
            break
        case "square":
            finalFrame = CGRectMake(bounds.width/2-b/5, bounds.height/2-b/5, b/2.5, b/2.5)
            break
        default: break
        }
        
        
        
        switch self.presentationAnimation {
        case .RectAlertViewOutOfCenter, .SquareAlertViewOutOfCenter:
            println("OutOfCenter")
            break
         
        case .SquareAlertViewOutOfTop, .RectAlertViewOutOfTop:
            println("OutOfTop")
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                var frame = CGRectMake(self.alertView.frame.origin.x, self.alertView.frame.origin.y, finalFrame.width, self.alertView.frame.height)
                self.alertView.frame = frame
            })
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                var frame = CGRectMake(finalFrame.origin.x, finalFrame.origin.y, self.alertView.frame.width, finalFrame.height)
                self.alertView.frame = frame
            })
            break
        
        case .RectNone, .SquareNone:
            self.alertView.frame = finalFrame
            break;
            
        default: break
        }
    }
    
    
    private class func hexColor(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    private var aTimer = NSTimer()
    private var aViews:[UIView] = []
    private func buildAnimationObject() {
        var center = CGPointMake(alertView.frame.width/2, alertView.frame.size.height*0.33)
        
        var size = CGSizeMake(25, 25)
        if title == nil {
            size = CGSizeMake(32,32)
            center = CGPointMake(alertView.frame.width/2, alertView.frame.size.height/2)
        }

        var viw = UIView()
        viw.clipsToBounds = true
        if backgroundStyle != .Dark {
            viw.layer.borderWidth = 1
            viw.layer.borderColor = HttpActivityAlert.hexColor(0xdddddd).CGColor
        }
        
        
        switch animationType {
            
        case .ColorCircleCover, .ColorCircleMutate:
            viw.layer.cornerRadius = size.width/2
            fallthrough
        case .ColorSquareCover, .ColorCircleCover:
            viw.frame = CGRectMake(0, 0, size.width, size.height)
            viw.center = center
            var frame = CGRectMake(0, 0, viw.frame.size.width, viw.frame.size.height)
            aViews = [UIView(frame: frame), UIView(frame: frame)];
            for view in aViews {
                viw.addSubview(view)
                view.backgroundColor = animationColors[0]
            }
            vibrancyView.addSubview(viw)
            break

            
        case .ColorSquareMutate, .ColorCircleMutate:
            viw.frame = CGRectMake(0, 0, size.width, size.height)
            viw.center = center
            var frame = CGRectMake(0, 0, viw.frame.size.width, viw.frame.size.height)
            aViews = [UIView(frame: frame)];
            aViews[0].backgroundColor = animationColors[0]
            viw.addSubview(aViews[0])
            vibrancyView.addSubview(viw)
            break
            
            
            
        case .RotatingSquare:
            viw.frame = CGRectMake(0, 0, size.width, size.height)
            viw.center = center
            aViews = [viw];
            viw.backgroundColor = animationColors[0]
            vibrancyView.addSubview(viw)
            break
            
           
        case .Circles:
            viw.frame = CGRectMake(0, 0, alertView.frame.height/3, alertView.frame.height/3)
            viw.center = center
            var frame = CGRectMake(viw.frame.width/2, 0, alertView.frame.width/10, alertView.frame.width/10)
            var frame2 = CGRectMake(viw.frame.width/2, alertView.frame.height/3 - alertView.frame.width/10, alertView.frame.width/10, alertView.frame.width/10)
            aViews = [UIView(frame: frame), UIView(frame: frame2)];
            for view in aViews {
                view.layer.cornerRadius = alertView.frame.width/20
                viw.addSubview(view)
                view.backgroundColor = animationColors[0]
            }
            vibrancyView.addSubview(viw)
            circlesAnimation(viw)
            break
            
        case .CirclesPendulum:
            var y = 1.5*alertView.frame.width/8
            var frame = CGRectMake(10, y, alertView.frame.width/8, alertView.frame.width/8)
            y += alertView.frame.width/8 + 3
            var frame1 = CGRectMake(10, y, alertView.frame.width/8, alertView.frame.width/8)
            y += alertView.frame.width/8 + 3
            var frame2 = CGRectMake(10, y, alertView.frame.width/8, alertView.frame.width/8)
            aViews = [UIView(frame: frame), UIView(frame: frame1), UIView(frame: frame2)];
            for view in aViews {
                viw.layer.borderColor = UIColor.darkGrayColor().CGColor
                viw.layer.borderWidth = 1
                view.layer.cornerRadius = alertView.frame.width/16
                vibrancyView.addSubview(view)
                view.backgroundColor = animationColors[0]
            }
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,Int64(0.12 * Double(NSEC_PER_SEC)))
            let delayTime2 = dispatch_time(DISPATCH_TIME_NOW,Int64(0.24 * Double(NSEC_PER_SEC)))
            self.circlesPendulumAnimation(self.aViews[0], direction: true)
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.circlesPendulumAnimation(self.aViews[1], direction: true)
            })
            dispatch_after(delayTime2, dispatch_get_main_queue(), { () -> Void in
                self.circlesPendulumAnimation(self.aViews[2], direction: true)
            })
            break
            
        default: break
        }
    }
    
    private func beginActivity() {
        if httpRequest == nil { return; }
        let task = NSURLSession.sharedSession().dataTaskWithRequest(
            self.httpRequest!,
            completionHandler: {
                data, response, error in
                
                if error != nil {
                    if self.delegate != nil {
                        self.delegate.httpRequestError(error.localizedDescription)
                        self.stop()
                    }
                } else {
                    if self.delegate != nil {
                        self.delegate.httpRequestSuccess(data, response: response)
                        self.stop()
                    }
                    
                }
        })
        task.resume()
    }
    
    /* --- build the private animations --- */
    private var index = 0;
    @objc private func coverAnimation(){
        
        var frame = self.aViews[1].frame;
        frame.origin.x -= frame.size.width;
        self.aViews[1].frame = frame;
        if ++self.index >= self.animationColors.count {self.index = 0 }
        self.aViews[1].backgroundColor = self.animationColors[self.index]
        
        UIView.animateWithDuration(0.35, animations: {
            () -> Void in
            self.aViews[1].frame = self.aViews[0].frame
            }, completion: { (bool) -> Void in
                self.aViews[0].backgroundColor = self.aViews[1].backgroundColor
        })
    }
    
    @objc private func mutateAnimation() {
        if ++self.index >= self.animationColors.count {self.index = 0 }
        UIView.animateWithDuration(0.55, animations: {
            () -> Void in
            self.aViews[0].backgroundColor = self.animationColors[self.index]
        })
    }
    
    @objc private func rotatingSquareAnimation(){
        if ++self.index >= self.animationColors.count {self.index = 0 }
        UIView.animateWithDuration(0.65, animations: {
            () -> Void in
            self.aViews[0].transform = CGAffineTransformRotate(self.aViews[0].transform, CGFloat(M_PI_2))
            self.aViews[0].backgroundColor = self.animationColors[self.index]
        })

    }
    
    @objc private func circlesAnimation(viw:UIView){
        if ++self.index >= self.animationColors.count {self.index = 0 }
        
        var duration = 0.5
        var angle = CGFloat(M_PI_2)
        var rotateTransform =  CGAffineTransformRotate(viw.transform, angle);
        UIView.animateWithDuration(duration, delay: 0, options: .CurveLinear, animations: {
            () -> Void in
            viw.transform = rotateTransform
            self.aViews[0].backgroundColor = self.animationColors[self.index]
            self.aViews[1].backgroundColor = self.animationColors[self.index]
            }) { (bool) -> Void in
                if self.animate { self.circlesAnimation(viw) }
        };
    }
    
    @objc private func circlesPendulumAnimation(viw:UIView, direction:Bool){
        if viw.isEqual(aViews[0]) {
            if ++self.index >= self.animationColors.count {self.index = 0 }
        }
        
        var frame = CGRectMake(10, viw.frame.origin.y, viw.frame.width, viw.frame.height)
        if direction { frame.origin.x = self.alertView.frame.width - viw.frame.width - 10 }
        
        UIView.animateWithDuration(0.65, animations: { () -> Void in
            viw.frame = frame
            viw.backgroundColor = self.animationColors[self.index]
        }) { (bool) -> Void in
            if self.animate { self.circlesPendulumAnimation(viw, direction: !direction) }
        };
    }
    
    @objc private func progressBarAnimation(){
        
    }
    
    
}