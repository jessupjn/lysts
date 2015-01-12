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

    @IBOutlet var viwImages : UIView!
    
    @IBOutlet var imgHeightConstraint : NSLayoutConstraint!

    private var _pagedImv : PagedURLImageView!
    
    private var _item : ListItem!
    func setItem(item : ListItem) {
        _item = item
    }
    
    override func viewWillAppear(animated: Bool) {
        var color = UIColor(red: 255.0/255, green: 170.0/255, blue: 55.0/255, alpha: 1.0)
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.navigationController!.navigationBar.barTintColor = color
        })
        self.navigationController?.navigationItem.backBarButtonItem?.title = "list"
        self.title = _item.getTitle()
        if _item.getImageLinks() != nil || _item.getImages() != nil {
            imgHeightConstraint.constant = 200
            self.view.layoutIfNeeded()
            
            _pagedImv = PagedURLImageView(frame: CGRectMake(0, 0, viwImages.frame.width, viwImages.frame.height))
            viwImages.addSubview(_pagedImv)
            
            var errorOccured = false
            if _item.getImageLinks() != nil { _pagedImv.setImages( _item.getImageLinks()!, error: {
                () -> Void in
                    self.imgHeightConstraint.constant = 60
                    self._pagedImv.removeFromSuperview()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.viwImages.backgroundColor = .lightGrayColor()
                        self.view.layoutIfNeeded()
                        }, completion: { (fin) -> Void in
                            if errorOccured { return }
                            
                            errorOccured = true
                            var lbl = UILabel(frame: CGRectMake(0, 0, self.viwImages.frame.width, self.viwImages.frame.height))
                            lbl.alpha = 0;
                            lbl.text = "error loading images"
                            lbl.textAlignment = .Center
                            lbl.textColor = .whiteColor()
                            lbl.font = UIFont(name: "AvenirNext-DemiBold", size: 12)!
                            self.viwImages.addSubview(lbl)
                            UIView.animateWithDuration(0.2, animations: {
                                () -> Void in
                                lbl.alpha = 1
                            })
                    })

                })
            } else { _pagedImv.setImages( _item.getImages()! ) }
        
        } else {
            imgHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func shareItem() {
        
    }
}