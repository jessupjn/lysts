//
//  HomeVC.swift
//  Lysts
//
//  Created by Jack on 12/9/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import LocalAuthentication

class HomeVC : UITableViewController, RNFrostedSidebarDelegate, ListEditVCDelegate, HttpActivityAlertDelegate, UIAlertViewDelegate {
    
    let singleton = Singleton.getSingleton()
    
    var _menu : RNFrostedSidebar!
    var _lists : [String]?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        self.tableView.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)
        self.view.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)
        var images : [UIImage] = [UIImage(named: "Btn-New-List")!.changeImageColor(UIColor.whiteColor()),
            UIImage(named: "Btn-Cam")!.changeImageColor(UIColor.whiteColor()),
            UIImage(named: "Btn-Settings")!.changeImageColor(UIColor.whiteColor()) ]
        _menu = RNFrostedSidebar(images: images)
        _menu.borderWidth = 2
        _menu.delegate = self
        
        var title:NSString = "mister lister";
        var attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSKernAttributeName, value:2.0, range:NSMakeRange(0,title.length));
        
        var size: CGSize = title.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(40.0)])
        var titleLabel : UILabel = UILabel(frame: CGRectMake((UIScreen.mainScreen().applicationFrame.size.width / 2.0) - ((size.width + 10.0) / 2.0), (self.navigationController!.navigationBar.frame.size.height / 2.0) - 30.0, size.width + 10.0, 60.0));
        
        titleLabel.font = UIFont(name:"Sprinklescolors", size: 33.0)
        titleLabel.attributedText = attributedTitle
        titleLabel.textColor = .whiteColor()
        titleLabel.clipsToBounds = false
        titleLabel.textAlignment = .Center
        self.navigationItem.titleView = titleLabel;
        var panGesture = UISwipeGestureRecognizer(target: self, action: "menuPanGesture:")
        panGesture.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(panGesture)
        
        var refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGrayColor()
        refreshControl.backgroundColor = singleton.UIColorFromHex(0xFAFAFF)
        refreshControl.addTarget(self, action: "actionRefreshControl", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl;
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        
        var tg = UITapGestureRecognizer(target: self, action: "scrollToTop")
        tg.numberOfTapsRequired = 2
        self.navigationController?.navigationBar.addGestureRecognizer(tg)
    }
    
    override func viewWillAppear(animated: Bool) {
        dataUpdated()
        var color = singleton.UIColorFromHex(0xE33A3A, alpha:1.0)
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.navigationController!.navigationBar.barTintColor = color

        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as UIViewController
        
        switch segue.identifier! {
        case "SEGUE_SHOW_CAMERA", "SEGUE_SHOW_SETTINGS":
            break
        case "SEGUE_VIEW_LIST":
            if let st = sender as? String {
                if let listViewVC = vc as? ListViewVC {
                    listViewVC.setList( singleton.getList(st)! )
                }
            }
            return
        case "SEGUE_LIST_INFO":
            var st = ""
            if let index = sender as? Int { st = _lists![index] }
            var list = singleton.getList(st)?
            if let listEditVC = vc as? ListEditVC { listEditVC.delegate=self; listEditVC.setListInfo(list) }
            break
        default:
            break
        }
    }
    
    func scrollToTop(){
        tableView.setContentOffset(CGPointMake(0,-63), animated: true)
    }
    
    func actionRefreshControl() {
        var user_prefs = singleton.getUserInformation()
        
        if singleton.getListOfLists() != nil {
            _lists = singleton.getListOfLists()
        } else if( singleton.createListOfLists() ) {
            actionRefreshControl()
            return
        }
        
        dispatch_after(1, dispatch_get_main_queue(), {
            self.updateTable()
        })
    }
    
    func sidebar(sidebar: RNFrostedSidebar!, didTapItemAtIndex index: UInt) {
        if index == 0 {
            self.performSegueWithIdentifier("SEGUE_LIST_INFO", sender: nil)
        }
        
        if index == 1 {
            
        }
        
        if index == 2 {
            var time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("SEGUE_SHOW_SETTINGS", sender: nil)
            })
        }
        sidebar.dismiss()

    }
    
    func updateTable() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func menuPanGesture(sender : UIPanGestureRecognizer){
        _menu.show()
    }
    
    @IBAction func btnMenuAction(sender:AnyObject){
        _menu.show()
    }
    
    @IBAction func btnCamAction(sender:AnyObject){
        
//        var url = NSURL(string: "http://www.outpan.com/api/get_product.php?barcode=23123123")
//        var req = NSURLRequest(URL: url!)
//        var hai = HttpActivityAlert(request: req, delegate: self)
////        var hai = HttpActivityAlert()
//        hai.title = "Loading..."
//        hai.animationType = HttpActivityAlertAnimationType.CirclesPendulum
//        hai.presentationAnimation = HttpActivityAlertPresentationType.SquareAlertViewOutOfTop
//        hai.backgroundStyle = .Dark
//        hai.start()
        self.performSegueWithIdentifier("SEGUE_SHOW_SETTINGS", sender: nil)
return
        
        if ( UIImagePickerController.isSourceTypeAvailable(.Camera) ) {
            // show camera
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                (granted) -> Void in
                if granted {
                    self.performSegueWithIdentifier("SEGUE_SHOW_CAMERA", sender: nil)
                } else {
                    UIAlertView(title: "Whoops!", message: "\nYou need to grant camera access to use this feature...\n\nPlease grant access in Settings -> Privacy -> Camera", delegate: self, cancelButtonTitle: "Okay").show()
                    println("no camera access granted")
                }
            })
        } else {
            // don't show camera
            UIAlertView(title: "Whoops!", message: "\nA camera could not be found\n on your device", delegate: self, cancelButtonTitle: "Okay").show()
//            JackAlertView.showWithTitle("Please grant camera access", ok_title: "Okay", showsCancelButton: true)
            println("camera unavailable")
        }

    }

    func tapButtons(sender:AnyObject){
        println(sender.frame)
        singleton.getProductInfo("078915030900", callback: {
            (data:Dictionary<String, AnyObject>, error:String?) -> Void in
            
            var name = data["name"] as String!
            var barcode = data["barcode"] as String!
            println("HomeVC: Got Response:\n\(barcode), \(name)")
        });
        
    }
}



//
//                              UITableView Delegate Methods
//
extension HomeVC {
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if _lists == nil {
            return 0
        } else {
            return _lists!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell;
        
        cell.backgroundColor = singleton.UIColorFromHex(0xFAFAFF, alpha: 1)

        if singleton.getList( _lists![indexPath.row] ) == nil {
            // if list object cannot be found
            _lists!.removeAtIndex(indexPath.row)
            tableView.reloadData()
            return cell
        }
        
        cell.textLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        cell.textLabel!.text = _lists![indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        
        var datelbl : UILabel!
        if cell.viewWithTag(1) == nil {
            datelbl = UILabel(frame: CGRectMake(cell.frame.width - 110,17,102,21))
            datelbl.text = "..."
            datelbl.tag = 1
            datelbl.font = UIFont.systemFontOfSize(10)
            datelbl.textColor = .darkGrayColor()
            cell.addSubview(datelbl)
            
//            // divider
//            var helper = UIView(frame: CGRectMake(cell.frame.width - 135, 10, 1, cell.frame.height - 20))
//            helper.backgroundColor = singleton.UIColorFromHex(0xDDDDDD, alpha: 1)
//            cell.addSubview(helper)
            
            var imv = UIImageView(frame: CGRectMake(cell.frame.width - 125,22,11,11))
            imv.image = UIImage(named: "img-clock")?.changeImageColor(.darkGrayColor())
            imv.contentMode = .ScaleAspectFill
            cell.addSubview(imv)
        }
        datelbl = cell.viewWithTag(1) as? UILabel
        
        // set last modified time
        var list = singleton.getList( _lists![indexPath.row] )
        var timeinterval = NSDate.timeIntervalSinceDate( list!.lastUpdated() )
        var date = NSDate()
        
        var gregorianCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        var components = gregorianCalendar.components(.DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit, fromDate: list!.lastUpdated(), toDate: date, options: nil)
        
        if components.day < 1 {
            if components.hour < 1 {
                if components.minute < 1 {
                    if components.second < 2 { datelbl.text = "\(components.second) second ago" }
                    else { datelbl.text = "\(components.second) seconds ago" }
                } else if components.minute < 2 { datelbl.text = "\(components.minute) minute ago" }
                else { datelbl.text = "\(components.minute) minutes ago" }
            } else if components.hour < 2 { datelbl.text = "\(components.hour) hour ago" }
            else { datelbl.text = "\(components.hour) hours ago" }
        } else if components.day < 2 { datelbl.text = "\(components.day) day ago" }
        else { datelbl.text = "\(components.day) days ago" }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var listName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        var list = singleton.getList(listName)!
        
        if list.isEncrypted() {
            let context = LAContext() // Get the local authentication context.
            var error: NSError? // Declare a NSError variable.
            var reasonString = "This list is encrypted... please use TouchID to view it."
            
            // Check if the device can evaluate the policy.
            if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                    
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.performSegueWithIdentifier("SEGUE_VIEW_LIST", sender: listName)                            
                        })
                    }
                    else{
                        // If authentication failed then show a message to the console with a short description.
                        // In case that the error is a user fallback, then show the password alert view.
                        println(evalPolicyError?.localizedDescription)
                        
                        switch evalPolicyError!.code {
                            
                        case LAError.SystemCancel.rawValue:
                            println("Authentication was cancelled by the system")
                            
                        case LAError.UserCancel.rawValue:
                            println("Authentication was cancelled by the user")
                            
                        case LAError.UserFallback.rawValue:
                            println("User selected to enter custom password")
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                                self.showPasswordAlert()
                            })
                            
                        default:
                            println("Authentication failed")
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                                self.showPasswordAlert()
                            })
                        }
                    }
                    
                })]
            }
        } else {
            self.performSegueWithIdentifier("SEGUE_VIEW_LIST", sender: listName)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var str = "        "
        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: str, handler:{action, indexpath in
            self.performSegueWithIdentifier("SEGUE_LIST_INFO", sender: indexPath.row)
            tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
        });
        var img = UIImage(named:"tbl_cell_edit")!
        var newSize = CGSizeMake(75, 55)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        img.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        moreRowAction.backgroundColor = UIColor(patternImage: newImage)
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: str, handler:{action, indexpath in
            
            tableView.cellForRowAtIndexPath(indexpath)?.setEditing(false, animated: true)
            if self.singleton.deleteList( self._lists![indexpath.row] ) {
                self._lists!.removeAtIndex(indexpath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexpath], withRowAnimation:.Right)
                self.tableView.endUpdates()
            }
        });
        img = UIImage(named:"tbl_cell_delete")!
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        img.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        deleteRowAction.backgroundColor = UIColor(patternImage: newImage)

        
        return [deleteRowAction, moreRowAction];
    }
}

extension HomeVC {
    
    func dataUpdated() {
        if singleton.getListOfLists() != nil {
            _lists = singleton.getListOfLists()
            tableView.reloadData()
        } else {
            singleton.createListOfLists()
            dataUpdated()
        }
    }
    
    func httpRequestError(errorDescription: NSString) {
        println("error")
    }
    func httpRequestSuccess(data: NSData, response: NSURLResponse) {
        println("success")
    }
}