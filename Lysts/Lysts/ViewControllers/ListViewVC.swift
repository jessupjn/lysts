//
//  ListViewVC.swift
//  Lysts
//
//  Created by Jack on 12/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class ListViewVC : UITableViewController {
    
    private var HEADER_HEIGHT_CONSTANT:CGFloat = 55

    var singleton = Singleton.getSingleton()
    var _list : [ListItem] = []
    
    var _selected:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)
        self.view.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)
        var scanBarButtonItem = UIBarButtonItem()
        self.navigationItem.backBarButtonItem = nil;
        
        var tg = UITapGestureRecognizer(target: self, action: "scrollToTop")
        tg.numberOfTapsRequired = 2
        self.navigationController?.navigationBar.addGestureRecognizer(tg)
    }
    
    func scrollToTop(){
        tableView.setContentOffset(CGPointMake(0,-HEADER_HEIGHT_CONSTANT), animated: true)
    }
    
    func setList(list:List){
        self.title = list.name()

        if let items = list.items() {
            _list = items
        }
        
        if(_list.isEmpty)
        {
            var urlList : [NSURL] = []
            urlList.append(NSURL(string: "http://www.webdesign.org/img_articles/15809/cog2.gif")!)
            urlList.append(NSURL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_KlXC3VXCxfzXUquL0SJUlrBMhwNhCqIOJ1glLJzbJC8tyVV6")!)
            var item = ListItem(title: "Mercury Soul", description: "This is a pretty cool car.. it is badass", imageUrls: urlList)
            _list.append(item)
            
            item = ListItem(title: "Honda Civic", description: "This is a bad car.. it stinks", imageUrls:nil)
            _list.append(item)
            
            item = ListItem(title: "Hummer - nuff said", description:nil, imageUrls:nil)
            _list.append(item)
            
            item = ListItem(title: "Caddy", description:nil, imageUrls:nil)
            _list.append(item)
            item = ListItem(title: "Audi", description:nil, imageUrls:nil)
            _list.append(item)
            item = ListItem(title: "General Motors", description:nil, imageUrls:nil)
            _list.append(item)

        }

//        var user_prefs = Singleton.getSingleton().getUserInformation().objectForKey(title)
//        if let list_obj = user_prefs as? List {
//            
//        }
    }
    
    func expandCell(sender:UIView, event:UIEvent) {
        
        var flag = false
        // get any touch on the buttonView
        if let touch = event.touchesForView(sender)?.anyObject() as? UITouch {
            // print the touch location on the button
            var point = touch.locationInView(tableView)
            
            if let v = find(_selected, sender.tag) {
                _selected.removeAtIndex(v)
            } else {
                _selected.append(sender.tag)
                flag = true
            }
        
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if flag {
                if point.y + 100 > tableView.contentOffset.y + tableView.frame.height {
                    var y = tableView.contentOffset.y + 100
                    tableView.setContentOffset(CGPointMake(tableView.contentOffset.x, y), animated: true)
                }
            }

        }
    }
    
    func btnActionEditItem(sender:UIView){
        self.performSegueWithIdentifier("SEGUE_EDIT_ITEM", sender: sender.tag)
    }
    
    func btnActiondeleteItem(sender:UIView){
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as UIViewController
        
        switch segue.identifier! {
        case "SEGUE_EDIT_ITEM":
//            (vc as ItemEditVC)
            break
        case "":
            break
        default:
            break
        }
    }
}

// UITableView Delegate Methods
extension ListViewVC {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _list.count > 0 ? _list.count : 1

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 55
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
        var item = _list[section]
        
        var viw = UIView(frame: CGRectMake(0,0,tableView.frame.width, HEADER_HEIGHT_CONSTANT))
        viw.backgroundColor = singleton.UIColorFromHex(0xF9F9FF, alpha: 0.93)
        
        // divider
        var helper = UIView(frame: CGRectMake(0,viw.frame.height - 1,viw.frame.width, 1))
        helper.backgroundColor = singleton.UIColorFromHex(0xDADADA, alpha: 1)
        viw.addSubview(helper)
        
        // list is empty
        if _list.count == 0 {
            helper = UILabel(frame: viw.frame)
            (helper as UILabel).textAlignment = .Center
            (helper as UILabel).text = "No Items to Diplay"
            (helper as UILabel).font = UIFont(name: "AvenirNext-DemiBold", size: 14)

            viw.addSubview(helper)
            return viw
        }
        
        // expand button
        helper = UIButton.buttonWithType(.Custom) as UIView
        helper.frame = viw.frame
        (helper as UIButton).setTitleColor(UIColor.orangeColor(), forState: .Normal)
        (helper as UIButton).addTarget(self, action: "expandCell:event:", forControlEvents: .TouchUpInside)
        helper.tag = section
        viw.addSubview(helper)
        
        // index label
        helper = UILabel(frame: CGRectMake(15, 0, 40, HEADER_HEIGHT_CONSTANT))
        (helper as UILabel).text = "\(section)"
        (helper as UILabel).textColor = singleton.UIColorFromHex(0xBBBBBB, alpha: 1)
        (helper as UILabel).font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        viw.addSubview(helper)
        
        // divider
        helper = UIView(frame: CGRectMake(50, 5, 1, HEADER_HEIGHT_CONSTANT - 10))
        helper.backgroundColor = singleton.UIColorFromHex(0xDDDDDD, alpha: 1)
        viw.addSubview(helper)
        
        // name label
        helper = UILabel(frame: CGRectMake(60, 0, tableView.frame.width - 70, HEADER_HEIGHT_CONSTANT))
        (helper as UILabel).text = _list[section].getTitle()
        (helper as UILabel).textColor = .darkGrayColor()
        (helper as UILabel).font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        viw.addSubview(helper)
        
        // edit button
        var color = singleton.UIColorFromHex(0x66CCCC, alpha: 1.0)
        helper = UIButton.buttonWithType(.Custom) as UIView
        helper.frame = CGRectMake(tableView.frame.width - 75, 15, HEADER_HEIGHT_CONSTANT - 30, HEADER_HEIGHT_CONSTANT - 30)
        var img = UIImage(named: "btn-edit-item")?.changeImageColor(color)
        (helper as UIButton).setImage(img, forState: .Normal)
        (helper as UIButton).setTitleColor(color, forState: .Normal)
        (helper as UIButton).addTarget(self, action: "btnActionEditItem:", forControlEvents: .TouchUpInside)
        helper.tag = section
        helper.layer.borderWidth = 1
        helper.layer.borderColor = color.CGColor
        helper.layer.cornerRadius = (HEADER_HEIGHT_CONSTANT - 30) / 2
        viw.addSubview(helper)

        // delete button
        color = singleton.UIColorFromHex(0xff6666, alpha: 1.0)
        helper = UIButton.buttonWithType(.Custom) as UIView
        helper.frame = CGRectMake(tableView.frame.width - 40, 15, HEADER_HEIGHT_CONSTANT - 30, HEADER_HEIGHT_CONSTANT - 30)
        img = UIImage(named: "btn-delete-item")?.changeImageColor(color)
        (helper as UIButton).setImage(img, forState: .Normal)
        (helper as UIButton).setTitleColor(color, forState: .Normal)
        (helper as UIButton).addTarget(self, action: "btnActionDeleteItem:", forControlEvents: .TouchUpInside)
        helper.tag = section
        helper.layer.borderWidth = 1
        helper.layer.borderColor = color.CGColor
        helper.layer.cornerRadius = (HEADER_HEIGHT_CONSTANT - 30) / 2
        viw.addSubview(helper)

        
        return viw
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as UITableViewCell;

        cell.textLabel!.text =  "\(indexPath.row)"
        cell.textLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)

//        // divider
//        var helper = UIView(frame: CGRectMake(50, 5, 1, HEADER_HEIGHT_CONSTANT - 10))
//        helper.backgroundColor = singleton.UIColorFromHex(0xDDDDDD, alpha: 1)
//        cell.addSubview(helper)
        
        // name label
        var helper = UILabel(frame: CGRectMake(60, 0, tableView.frame.width - 70, HEADER_HEIGHT_CONSTANT))
        (helper as UILabel).text = _list[indexPath.row].getTitle()
        (helper as UILabel).textColor = .darkGrayColor()
        (helper as UILabel).font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        cell.addSubview(helper)
        
//        var pagedImv = PagedURLImageView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.width/3))
//        pagedImv.setURLS(["a", "b", "c"])
//        pagedImv.clipsToBounds = true
//        cell.contentView.addSubview(pagedImv)
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var str = "        "
        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: str,
            handler:{action, indexpath in
            println("MORE•ACTION");
        });
        var img = UIImage(named:"tbl_cell_edit")!
        var newSize = CGSizeMake(75, 55)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        img.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        moreRowAction.backgroundColor = UIColor(patternImage: newImage)
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: str, handler:{action, indexpath in
            println("DELETE•ACTION");
        });
        img = UIImage(named:"tbl_cell_delete")!
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        img.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        deleteRowAction.backgroundColor = UIColor(patternImage: newImage)
        
        
        return [deleteRowAction, moreRowAction];
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}