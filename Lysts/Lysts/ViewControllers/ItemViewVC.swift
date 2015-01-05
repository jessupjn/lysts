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
        if _item.getImages() != nil {
            imgHeightConstraint.constant = 200
            self.view.layoutIfNeeded()
            
            _pagedImv = PagedURLImageView(frame: CGRectMake(0, 0, viwImages.frame.width, viwImages.frame.height))
            viwImages.addSubview(_pagedImv)
            
            _pagedImv.setURLS( _item.getImages()! )
        
        } else {
            imgHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func shareItem() {
        
    }
}