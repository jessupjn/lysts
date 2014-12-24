//
//  LystsNavigationBar.swift
//  Lysts
//
//  Created by Jack on 12/9/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class LystsNavigationBar : UINavigationBar {
    
    // consts
    let NAVIGATION_BAR_HEIGHT_INCREASE:CGFloat = 10.0
    
    // variables
    
    override func drawRect(rect: CGRect) {
        println(rect)
        var bounds = rect
        var context = UIGraphicsGetCurrentContext();
        var redColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        CGContextSetFillColorWithColor(context, redColor.CGColor)
        CGContextFillRect(context, self.bounds);
        
        redColor = .orangeColor()
        bounds.origin.y = bounds.height - 3
        bounds.size.height = 3
        
    }


}