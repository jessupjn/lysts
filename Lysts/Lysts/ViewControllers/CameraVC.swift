//
//  CameraVC.swift
//  Lysts
//
//  Created by Jack on 12/12/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraVC : UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    //
    //  variable bank
    //
    var singleton = Singleton.getSingleton()
    
    var _session : AVCaptureSession!
    var _device : AVCaptureDevice!
    var _input : AVCaptureDeviceInput!
    var _output : AVCaptureMetadataOutput!
    var _previewLayer : AVCaptureVideoPreviewLayer!
    
    @IBOutlet var _resultsHeightConstraint : NSLayoutConstraint!
    @IBOutlet var _activityIndicator : UIActivityIndicatorView!
    @IBOutlet var _highlightView : UIView!
    @IBOutlet var _resultsView : UIView!
    var _btnFindInfo : UIButton!
    var _btnAddInfo : UIButton!
    var _label : UILabel!

    var album : String?
    
    //
    //  overridden functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        _resultsHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        _session.stopRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        var barCodeObject : AVMetadataMachineReadableCodeObject!
        var detectionString = NSString()
        var barCodeTypes:[NSString] = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
        var dataObjects = metadataObjects as! [AVMetadataObject]
        
        for metadata in dataObjects {
            for type:NSString in barCodeTypes {
                if (metadata as AVMetadataObject).type == type {

                    barCodeObject = _previewLayer.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    if highlightViewRect.width < 20 { highlightViewRect.size.width = 20 }
                    if highlightViewRect.height < 20 { highlightViewRect.size.height = 20 }
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    break;
                }
            }
        }
        
        if self._resultsHeightConstraint.constant == 0 && detectionString.length > 0 {
            self._resultsHeightConstraint.constant = 45
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self._activityIndicator.startAnimating()
            }, completion: { (done) -> Void in
                let w : CGFloat = 20;
                var x : CGFloat = (UIScreen.mainScreen().bounds.width - (w * CGFloat(detectionString.length)))/2;
                
                var dict = NSMutableDictionary()
                dict.setObject(detectionString, forKey: "string")
                dict.setObject(0, forKey: "currIndex")
                dict.setObject(x, forKey: "x-value")
                dict.setObject(w, forKey: "w-value")
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "showDetectedBarcode:", userInfo: dict, repeats: true)
                timer.fire()
                
            });
        }
        
        _highlightView.layer.frame = highlightViewRect;
    }
    
    func showDetectedBarcode(timer:NSTimer) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            var s = timer.userInfo?.objectForKey("string") as! String
            var index = timer.userInfo?.objectForKey("currIndex") as! CGFloat
            var x = timer.userInfo?.objectForKey("x-value") as! CGFloat
            var w = timer.userInfo?.objectForKey("w-value") as! CGFloat
            
            var lbl = UILabel(frame: CGRectMake(x+(w*index), 10, w, w))
            lbl.textColor = .blackColor()
            lbl.textAlignment = .Center
            lbl.font = UIFont(name: "AvenirNext-DemiBold", size: 1)
            
            var start = advance(s.startIndex, Int(index))
            lbl.text = String( s[start] )
            self._resultsView.addSubview(lbl)
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                lbl.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
                }) { (c) -> Void in
                    UIView.animateWithDuration(0.07, animations: { () -> Void in
                        lbl.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
                    })
            }
            x += 20
            
            timer.userInfo?.setObject( ++index, forKey: "currIndex")
            if index == CGFloat( count(s) ) {
                timer.invalidate()
            }
            
        })
    }
    
    //
    //  other various shit
    //
    func setupCamera() {
        _highlightView.layer.borderWidth = 1
        _highlightView.layer.borderColor = UIColor.greenColor().CGColor
        
        _session = AVCaptureSession()
        _device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSErrorPointer = nil
        
        _input = AVCaptureDeviceInput.deviceInputWithDevice(_device, error: error) as! AVCaptureDeviceInput
        if _input != nil {
            _session.addInput( _input )
        } else {
            println("Error: \(error)");
        }
            
        _output = AVCaptureMetadataOutput()
        _output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        _session.addOutput(_output)
        
        _output.metadataObjectTypes = _output.availableMetadataObjectTypes
        
        _previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(_session) as! AVCaptureVideoPreviewLayer
        _previewLayer.frame = self.view.bounds
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        _previewLayer.zPosition = -5
        self.view.layer.addSublayer(_previewLayer)
        self.view.layer.addSublayer(_highlightView.layer)
        
        _session.startRunning()
        
        var xButton = UIButton.buttonWithType(.Custom) as! UIButton
        xButton.frame = CGRectMake(10,10,46,30)
        xButton.titleLabel!.text = "X"
        xButton.titleLabel!.font = .systemFontOfSize(30)
        xButton.titleLabel!.textColor = .whiteColor()
//        self.view.addSubview(xButton)
    }
    
    @IBAction func btnXAction(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}