//
//  ListItem.swift
//  Lysts
//
//  Created by Jack on 12/17/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation


class ListItem : NSObject, NSCoding {

    private
    var _title:String!
    var _description:String?
    var _imageUrls:[NSURL]?
    var _images:[UIImage]?
    var _dateModified:NSDate!
    
    internal
    init(title:String, description:String?, imageUrls:[NSURL]?) {
        super.init()
        _title = title
        _description = description
        _imageUrls = imageUrls
        _dateModified = NSDate()

    }
    
    init(title:String, description:String?, images:[UIImage]?) {
        super.init()
        _title = title
        _description = description
        _images = images
        _dateModified = NSDate()        
    }
    
    required init(coder aDecoder: NSCoder) {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
    }
    
    func getNumberOfRows() -> Int {
        var count:Int = 0;
        if _title != nil { count++ }
        if _description != nil { count++ }
        if _imageUrls != nil { count++ }
        
        
        return count
    }
    
    func getTitle() -> String! {
        if let t = _title { return t }
        else { return nil }
    }
    
    func getDescription() -> String? {
        if let t = _description { return t }
        else { return nil }
    }
    
    func getImages() -> [UIImage]? {
        if let t = _images {
            if t.count > 0 { return t }
            else { return nil }
        } else { return nil }
    }
    
    func getImageLinks() -> [NSURL]? {
        if let t = _imageUrls {
            if t.count > 0 { return t }
            else { return nil }
        } else { return nil }
    }
}