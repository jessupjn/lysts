//
//  BarcodeLookup.swift
//  Lysts
//
//  Created by Jack on 12/10/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation

class BarcodeLookup : NSObject {
    
    // DEVELOPER INFO
    // http://www.outpan.com/developers.php

    
    private
    let API_KEY = "408807d68df1c7551ea6bf4858444642e19ce641"
    let URL_STRING = "http://www.outpan.com/api/get_product.php?"
    
    internal
    func makeRequest(barcode:NSString, callback:(Dictionary<String, AnyObject>, String?)->Void)
    {
        var stringUrl = URL_STRING
//        stringUrl += "apikey=" + API_KEY
//        stringUrl += "&barcode=" + barcode
        stringUrl += "barcode=" + barcode
        
        let url = NSURL(string: stringUrl) // Creating URL
        var request = NSMutableURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(
            request,
            {
                data, response, error in
                
                println("Made Request For: \(barcode)")
                if error != nil {
                    callback(Dictionary<String, AnyObject>(), error.localizedDescription)
                } else {
                    var jsonObj = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as Dictionary<String, AnyObject>
                    callback(jsonObj, nil)
                }
        })
        
        println("Made Request For: \(barcode)")
        println("URL: \(stringUrl)")
        task.resume()
    }
    
}