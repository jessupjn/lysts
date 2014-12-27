//
//  Singleton.swift
//  
//
//  Created by Jackson Jessup on 8/22/14.
//
//

import Foundation
import UIKit

private
let lookupBarcode = BarcodeLookup();

internal
let _Singleton : Singleton = Singleton()

class Singleton : NSObject
{
    class func getSingleton() -> Singleton {
        return _Singleton
    }

    func getUserInformation() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}


//
//                      MODIFYING OUR DATA IN MEMORY OF LISTS
//
extension Singleton {
    
    func createListOfLists() -> Bool {
        if getListOfLists() == nil {
            var list:[String] = []
            getUserInformation().setObject(list, forKey: "LIST_TITLES")
            return getUserInformation().synchronize()
        }
        return false
    }
    
    func getListOfLists() -> [String]? {
        let list = getUserInformation().objectForKey("LIST_TITLES") as? [String]
        return list==nil ? nil : list
    }
    
    func getList(name:String?) -> List? {
        if name == nil { return nil }
        let data = getUserInformation().objectForKey(name!) as? NSData
        if data == nil { return nil }
        let list = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? List
        return list==nil ? nil : list
    }
    
    func setList(list:List, newList:Bool) -> Bool {
        var L = getListOfLists()!
        if newList { L.append(list.name()) }
        getUserInformation().setObject(L, forKey: "LIST_TITLES")
        return updateListItems(list)
    }
    
    func updateListItems(list:List) -> Bool {
        getUserInformation().setObject(NSKeyedArchiver.archivedDataWithRootObject(list), forKey: list.name())
        return getUserInformation().synchronize()
    }
    
    func createOrEditList(list_obj:List, new_list_obj:List?) -> Bool {
        
        var list = getListOfLists()
//        if(list == nil) createListOfLists()
        
        if let index = find(list!, list_obj.name()) {
            if(new_list_obj != nil) {
                
                // modify name in list
                list![index] = new_list_obj!.name()
                getUserInformation().setObject(list, forKey: "LIST_TITLES")
                
                // delete old list object
                getUserInformation().removeObjectForKey(list_obj.name())

                // set new list object
                return setList( new_list_obj!, newList:false )
            } else {
                return false // name in use
            }
        } else {
            return setList(list_obj, newList:true ) // create new list
        }
    }
    
    func deleteList(name:String) -> Bool {
        var list = getListOfLists()
        if let index = find(list!, name) {
            getUserInformation().removeObjectForKey(name)
            list!.removeAtIndex(index)
        }
        return getUserInformation().synchronize()
    }
    
    
}



//
//                      GETTING INFORMATION OF PRODUCTS
//
extension Singleton {
    
    func getProductInfo(barcode:NSString, callback:(Dictionary<String, AnyObject>, String?)->Void)
    {
        lookupBarcode.makeRequest(barcode, callback: callback)
    }
}