//
//  PagedURLImageView.swift
//  Lysts
//
//  Created by Jack on 12/17/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class PagedURLImageView : UIView, UIScrollViewDelegate {
        
    private var scrlViw = UIScrollView()
    private var loadScrn = UIView()
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    private var pageIndicator = UIPageControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add scrollview
        scrlViw.frame = CGRectMake(-1, 0, frame.width+2, frame.height)
        scrlViw.delegate = self
        scrlViw.decelerationRate = UIScrollViewDecelerationRateFast
        scrlViw.pagingEnabled = true
        scrlViw.showsHorizontalScrollIndicator = false
        scrlViw.backgroundColor = .lightGrayColor()
        scrlViw.layer.borderColor = UIColor.lightGrayColor().CGColor
        scrlViw.layer.borderWidth = 1
        self.addSubview(scrlViw)

        // add paging
        pageIndicator.frame = CGRectMake(0,frame.height - 20, frame.width, 20)
        pageIndicator.numberOfPages = 2
        pageIndicator.currentPageIndicatorTintColor = .darkGrayColor()
        pageIndicator.pageIndicatorTintColor = .lightGrayColor()
        self.addSubview(pageIndicator)

        // load screen
        loadScrn.frame = CGRectMake(0, 0, frame.width, frame.height)
        loadScrn.backgroundColor = Singleton.getSingleton().UIColorFromHex(0x000000, alpha: 0.6)
        self.addSubview(loadScrn)
        loadScrn.hidden = true
        
        // spinner
        spinner.frame = CGRectMake(0, 0, 30, 30)
        spinner.center = loadScrn.center
        spinner.hidesWhenStopped = true
        loadScrn.addSubview(spinner)
        println(loadScrn.frame)
        println(spinner.center)
        
        self.backgroundColor = .clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init()
//        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageLoadCount = 0
    func setURLS(urls:[NSURL]) {
        pageIndicator.numberOfPages = urls.count
    
        loadScrn.hidden = false
        spinner.startAnimating()
        
        var horizontal_jump = scrlViw.frame.width
        var x:CGFloat = 0
        for url in urls {
            var imv = UIImageView(frame: CGRectMake(x, -63, scrlViw.frame.width, scrlViw.frame.height))
            imv.contentMode = UIViewContentMode.ScaleAspectFit
            scrlViw.addSubview(imv)
            self.UIImageFromURL(url, successBlock: { (image) -> Void in
                imv.image = image
                if ++self.imageLoadCount == urls.count {
                    self.spinner.stopAnimating()
                    self.loadScrn.removeFromSuperview()
                }
            }, errorBlock: { () -> Void in
                println("error loading image")
            })
            x += horizontal_jump
        }
        scrlViw.contentSize = CGSizeMake(x, 10)
        scrlViw.contentOffset = CGPointMake(0, 0)
    }
    
    func setImages(images:[UIImage]) {
        pageIndicator.numberOfPages = images.count
        
        loadScrn.hidden = false
        spinner.startAnimating()
        var horizontal_jump = scrlViw.frame.width
        var x:CGFloat = 0
        
        for image in images {
            var imv = UIImageView(frame: CGRectMake(x, -63, scrlViw.frame.width, scrlViw.frame.height))
            imv.image = image
            scrlViw.addSubview(imv)
            x += horizontal_jump
        }
        scrlViw.contentSize = CGSizeMake(x, 10)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var pageNum = (scrollView.contentOffset.x + (scrollView.frame.width/2))
        pageNum = pageNum / scrollView.frame.width
        var Index:Int = Int(pageNum)
        pageIndicator.currentPage = Index
    }
    
    private func UIImageFromURL(URL:NSURL, successBlock : (image:UIImage)->Void, errorBlock : () ->Void) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), {
            () -> Void in
            var data = NSData(contentsOfURL: URL)
            var image = UIImage(data: data!)
            dispatch_async( dispatch_get_main_queue(), {
                () -> Void in
                if image != nil { successBlock(image: image!) }
                else { errorBlock() }
            })
        })
    }
    
}