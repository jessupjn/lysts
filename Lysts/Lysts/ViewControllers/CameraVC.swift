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
                    if highlightViewRect.width < 20 { highlightViewRect.size.width = 20 }
                    if highlightViewRect.height < 20 { highlightViewRect.size.height = 20 }
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
    
    @IBAction func btnXAction(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}