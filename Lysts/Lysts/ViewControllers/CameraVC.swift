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
    @IBOutlet var _highlightView : UIView!
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
        var detectionString : NSString!
        var barCodeTypes:[NSString] = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
        var dataObjects = metadataObjects as [AVMetadataObject]
        
        for metadata in dataObjects {
            for type:NSString in barCodeTypes {
                if (metadata as AVMetadataObject).type == type {

                    barCodeObject = _previewLayer.transformedMetadataObjectForMetadataObject(metadata as AVMetadataMachineReadableCodeObject) as AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    if highlightViewRect.width > 20 { highlightViewRect.size.width = 20 }
                    if highlightViewRect.height > 20 { highlightViewRect.size.height = 20 }
                    detectionString = (metadata as AVMetadataMachineReadableCodeObject).stringValue
                    break;
                }
            }
        }
        
        if detectionString == nil {
        
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self._resultsHeightConstraint.constant = 45
                self.view.layoutIfNeeded()
            })
        }
        
        _highlightView.layer.frame = highlightViewRect;
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
        
        _input = AVCaptureDeviceInput.deviceInputWithDevice(_device, error: error) as AVCaptureDeviceInput
        if _input != nil {
            _session.addInput( _input )
        } else {
            println("Error: \(error)");
        }
            
        _output = AVCaptureMetadataOutput()
        _output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        _session.addOutput(_output)
        
        _output.metadataObjectTypes = _output.availableMetadataObjectTypes
        
        _previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(_session) as AVCaptureVideoPreviewLayer
        _previewLayer.frame = self.view.bounds
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        _previewLayer.zPosition = -5
        self.view.layer.addSublayer(_previewLayer)
        self.view.layer.addSublayer(_highlightView.layer)
        
        _session.startRunning()
        
        var xButton = UIButton.buttonWithType(.Custom) as UIButton
        xButton.frame = CGRectMake(10,10,46,30)
        xButton.titleLabel!.text = "X"
        xButton.titleLabel!.font = .systemFontOfSize(30)
        xButton.titleLabel!.textColor = .whiteColor()
//        self.view.addSubview(xButton)
    }
    
    var viewShown:Bool = false
    func showAcceptView(code:NSString){
        if !viewShown {
            viewShown = true
            var bounds = UIScreen.mainScreen().bounds
            bounds.origin.y = bounds.height
            bounds.origin.x = 0
            bounds.size.width = bounds.width
            bounds.size.height = 80

            var blur = UIBlurEffect(style:.Dark)
            var blurView = UIVisualEffectView(effect: blur)
            var vibrancy = UIVibrancyEffect(forBlurEffect: blurView.effect as UIBlurEffect)
            var vibrancyView = UIVisualEffectView(effect: vibrancy)

            vibrancyView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            blurView.contentView.addSubview(vibrancyView)
            blurView.frame = bounds
            blurView.tag = 1
            
            blurView.contentView.layer.cornerRadius = 20
            blurView.layer.cornerRadius = 20
            vibrancyView.contentView.layer.cornerRadius = 20
            vibrancyView.layer.cornerRadius = 20
            
            self.view.addSubview(blurView)
            
            _label = UILabel(frame: CGRectMake(0, 0, blurView.frame.width, 23))
            _label.textColor = .whiteColor()
            _label.textAlignment = .Center
            _label.text = code
            blurView.addSubview( _label )
            
            
            bounds.origin.y = UIScreen.mainScreen().bounds.height - 75
            UIView.animateWithDuration(0.25, animations: {
                () -> Void in
                blurView.frame = bounds
            }, completion: {
                (complete) -> Void in
                
                var autoGrab = self.singleton.getUserInformation().boolForKey("SETTINGS_AUTO_GRAB_INFO")
                if self.singleton.getUserInformation().objectForKey("SETTINGS_AUTO_GRAB_INFO") == nil {
                    // prompt user to see if they want to get info
                } else if autoGrab {
                    // GET INFO FOR ITEM
                } else {
                    // add button to move forward
                }
            })
            
        } else {
            println( self.view.viewWithTag(1) )
        }
    }
    
    @IBAction func btnXAction(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}