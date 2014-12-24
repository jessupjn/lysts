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
        scrlViw.frame = frame
        scrlViw.delegate = self
        scrlViw.decelerationRate = UIScrollViewDecelerationRateFast
        scrlViw.pagingEnabled = true
        scrlViw.showsHorizontalScrollIndicator = false
        self.addSubview(scrlViw)

        // add paging
        pageIndicator.frame = CGRectMake(0,frame.height - 20, frame.width, 20)
        pageIndicator.numberOfPages = 2
        pageIndicator.currentPageIndicatorTintColor = .darkGrayColor()
        pageIndicator.pageIndicatorTintColor = .lightGrayColor()
        self.addSubview(pageIndicator)

        // load screen
        loadScrn.frame = frame
        loadScrn.backgroundColor = Singleton.getSingleton().UIColorFromHex(0x000000, alpha: 0.6)
        self.addSubview(loadScrn)
        loadScrn.hidden = true
        
        // spinner
        spinner.frame = CGRectMake(0, 0, 30, 30)
        spinner.center = loadScrn.center
        loadScrn.addSubview(spinner)
        println(loadScrn.frame)
        println(spinner.center)
        
        self.backgroundColor = .clearColor()
    }
    
    func setURLS(urls:[String]) {
        pageIndicator.numberOfPages = urls.count
    
        loadScrn.hidden = false
        
        var horizontal_jump = scrlViw.frame.width
        var x:CGFloat = 0
        for url in urls {
            var imv = UIImageView(frame: CGRectMake(x, 0, scrlViw.frame.width, scrlViw.frame.height))
            
            scrlViw.addSubview(imv)
            x += horizontal_jump
        }
        scrlViw.contentSize = CGSizeMake(x, 10)
    }
    
    convenience required init(coder: NSCoder) {
        self.init(coder: coder)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var pageNum = (scrollView.contentOffset.x + (scrollView.frame.width/2))
        pageNum = pageNum / scrollView.frame.width
        var Index:Int = Int(pageNum)
        pageIndicator.currentPage = Index
        println(Index)
        
    }
    
}