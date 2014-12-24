//
//  List.swift
//  Lysts
//
//  Created by Jack on 12/16/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation

class List : NSObject, NSCoding {
    
    // properties of the List
    private
    var KEY_NAME = "name"
    var KEY_LAST_UPDATED = "last_modified"
    var KEY_ITEMS = "items"
    
    var _name : String!
    var _last_updated : NSDate!
    var _items : [ListItem]!
    
    internal
    init(name:String) {
        super.init()
        
        _name = name
        _last_updated = NSDate()
        _items = []
    }
    
    required init(coder aDecoder: NSCoder) {
        self._name  = aDecoder.decodeObjectForKey(KEY_NAME) as? String
        self._last_updated  = aDecoder.decodeObjectForKey(KEY_LAST_UPDATED) as? NSDate
        self._items  = aDecoder.decodeObjectForKey(KEY_ITEMS) as? [ListItem]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_name, forKey: KEY_NAME)
        aCoder.encodeObject(_last_updated, forKey: KEY_LAST_UPDATED)
        aCoder.encodeObject(_items, forKey: KEY_ITEMS)
    }
    
    func deleteItem(index:Int){
        
        Singleton.getSingleton()
    }
    
    func name() -> String { return _name }
    func lastUpdated() -> NSDate { return _last_updated }
    func items() -> [ListItem]? { return _items }
    
    func setName(name:String) { _name = name }
    func addItem(item:ListItem) { _items.append(item) }
}