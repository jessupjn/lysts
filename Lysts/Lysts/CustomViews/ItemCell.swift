//
//  ItemCell.swift
//  Lysts
//
//  Created by Jack on 12/17/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class ItemCell : UITableViewCell {
    
    @IBOutlet var lblQuantity : UILabel?
    @IBOutlet var lblName : UILabel?
    
    var _item : ListItem!
        
    init(item:ListItem) {
        super.init(style: .Default, reuseIdentifier: "itemCell")
        setItem(item)
    }

    func setItem(item:ListItem){
        _item = item
        if let lbl = lblQuantity {
            lbl.text = "#"
        }
        if let lbl = lblName {
            lbl.text = "name"
        }
    }
    
    class func computeHeight(i:ListItem)->CGFloat{
        return 150;
    }
    
    func modifyheight() {
        var frame = self.frame
        if frame.height < 5 {
            frame.size.height = 50
        } else {
            frame.size.height = 0
        }
        self.frame = frame
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}