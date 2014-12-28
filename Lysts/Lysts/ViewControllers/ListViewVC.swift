//
//  ListViewVC.swift
//  Lysts
//
//  Created by Jack on 12/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

class ListViewVC : UITableViewController, JLActionSheetDelegate {
    
    private var HEADER_HEIGHT_CONSTANT:CGFloat = 55

    var singleton = Singleton.getSingleton()
    var _listInfo : List!
    var _list : [ListItem] = []
    @IBOutlet var _navItem :UINavigationItem!
    var _selected:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)
        self.view.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)
        var scanBarButtonItem = UIBarButtonItem()
        
        var tg = UITapGestureRecognizer(target: self, action: "scrollToTop")
        tg.numberOfTapsRequired = 2
        self.navigationController?.navigationBar.addGestureRecognizer(tg)
    }
    
    override func viewWillAppear(animated: Bool) {
        var color = UIColor(red: 83.0/255, green: 195.0/255, blue: 193.0/255, alpha: 1.0)
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.navigationController!.navigationBar.barTintColor = color
        })
        self.title = _listInfo.name()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = "list"
    }
    
    func scrollToTop(){
        tableView.setContentOffset(CGPointMake(0,-63), animated: true)
    }
    
    func setList(list:List){

        _listInfo = list
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
    
    @IBAction func btnActionAddNew(sender:UIBarButtonItem){
        var actionSheet = JLActionSheet(title: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: ["Scan Barcode", "Add Item"])
        actionSheet.style = JLSTYLE_MISTERLISTER
        actionSheet.showOnViewController(self)
    }
    
    func endEditing() { self.view.endEditing(true) }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as UIViewController
        
        switch segue.identifier! {
        case "SEGUE_EDIT_ITEM":
            if sender != nil { (vc as ItemEditVC).setItemInfo(sender as ListItem)}
            break
        case "SEGUE_VIEW_ITEM":
//            (vc as ItemViewVC).setItem( _list[ (sender as NSIndexPath).row ] )
            break
        case "SEGUE_SHOW_CAMERA":
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as UITableViewCell;

        cell.textLabel!.text =  "\(indexPath.row)"
        cell.textLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
        cell.backgroundColor = .clearColor()
        cell.accessoryType = .DisclosureIndicator
//        // divider
//        var helper = UIView(frame: CGRectMake(50, 5, 1, HEADER_HEIGHT_CONSTANT - 10))
//        helper.backgroundColor = singleton.UIColorFromHex(0xDDDDDD, alpha: 1)
//        cell.addSubview(helper)
        
        // name label
        var helper = UILabel(frame: CGRectMake(45, 0, tableView.frame.width - 70, HEADER_HEIGHT_CONSTANT))
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var str = "        "
        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: str,
            handler:{action, indexpath in
            
                self.performSegueWithIdentifier("SEGUE_EDIT_ITEM", sender: self._list[indexPath.row])

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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("SEGUE_VIEW_ITEM", sender: indexPath.row)
    }
}


// JLActionSheet delegate methods
extension ListViewVC {
    func actionSheet(actionSheet: JLActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch actionSheet.titleAtIndex(buttonIndex).lowercaseString {
        case "scan barcode":
            println("Open camera")
            self.performSegueWithIdentifier("SEGUE_SHOW_CAMERA", sender: nil)
            break
        case "add item":
            println("Add item")
            self.performSegueWithIdentifier("SEGUE_EDIT_ITEM", sender: nil)
            break
        default:
            break
        }
    }
}