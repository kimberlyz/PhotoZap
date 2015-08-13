//
//  AlbumViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse
import CTAssetsPickerController
import ReachabilitySwift
import RealmSwift
import AMPopTip

class AlbumViewController: UIViewController, CTAssetsPickerControllerDelegate {
    
    //var assets : [AnyObject] = []
    //var transaction : Transaction?
    
    @IBOutlet weak var WiFiButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    let reachability = Reachability.reachabilityForInternetConnection()

    var zapBool : Bool?
    
    let infoPopTip = AMPopTip()
    
    // checks whether you have been notified that you are on wi-fi when app launches
    var firstWarning = true
    
//    var transactions: Results<Transaction>! {
//        didSet {
//            // Whenever notes update, update the table view
//            println("Transaction assigned")
//        }
//    }
    
    /*
    var freshLaunch = true
    override func viewWillAppear(animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
            self.tabBarController!.selectedIndex = 1 // 2nd tab
        }
    } */
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//    }
    

  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        reachability.startNotifier()
        
        let realm = Realm()
        
        if reachability.isReachableViaWiFi(){
            
            WiFiButton.setTitle("Wi-Fi", forState: .Normal)

            if firstWarning && realm.objects(PendingNotification).first != nil  {
                
                SweetAlert().showAlert("You have Wi-Fi!", subTitle: "Would you like to send your pending notifications now?", style: AlertStyle.None, buttonTitle:"No", buttonColor: UIColor.colorFromRGB(0x66B2FF) , otherButtonTitle:  "Yes", otherButtonColor: UIColor.colorFromRGB(0x66B2FF/*0x90AEFF*/)) { (isOtherButton) -> Void in
                    if isOtherButton == true {
                        // nothing
                    }
                    else {
                        self.tabBarController!.selectedIndex = 1
                        /// DO SOMETHING HERE!!!!! SEND IT
                        //SweetAlert().showAlert("Image sent!", subTitle: "", style: AlertStyle.Success)
                    }
                }
                
                firstWarning = false
            }
        } else {
            WiFiButton.setTitle("Wi-Fi Delay", forState: .Normal)
        }

    }
    
    @IBAction func zapButtonTapped(sender: AnyObject) {
        zapBool = true
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let sendPhotoAction = UIAlertAction(title: "Send Photo", style: .Default) { (action) in
            self.showAlbum()
        }
        
        let receivePhotoAction = UIAlertAction(title: "Receive Photo", style: .Default) { (action) in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let receiveZap = mainStoryboard.instantiateViewControllerWithIdentifier("ReceiveZapNavigation") as! UINavigationController
            self.presentViewController(receiveZap, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(sendPhotoAction)
        alertController.addAction(receivePhotoAction)
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
            
        // showAlbum()
    }
    
    @IBAction func wifiButtonTapped(sender: AnyObject) {
        if reachability.isReachable() {
            zapBool = false
            showAlbum()
        } else {
            SweetAlert().showAlert("No connection.", subTitle: "Sorry, can't send right now.", style: AlertStyle.Error)
        }

    }
    
    @IBAction func infoButton(sender: AnyObject) {


        //let rect = self.view.convertRect(rect: infoButton.frame, fromView: infoButton.superview)
        
        //CGRect rect = self.view.convertRect(infoButton.frame, fromView: infoButton.superview)
        
        infoPopTip.shouldDismissOnTap = true
        infoPopTip.popoverColor = UIColor.colorFromRGB(0x2664C1)
        infoPopTip.borderColor = UIColor.colorFromRGB(0x2664C1)

        if infoPopTip.isVisible {
            infoPopTip.hide()
        } else {
            infoPopTip.showText("Instantly send photos.\nSome setup required.", direction: .Right, maxWidth: 200, inView: self.view, fromFrame: infoButton.frame)
        }

    }

    
    func showAlbum() {
        
        
        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue()) {
                
                switch (status)
                {
                case .Authorized:
                    println("Authorized")
                    
                case .Denied:
                    println("Denied")
                case .Restricted:
                    println("Restricted")
                    
                case .NotDetermined:
                    println("Not determined")
                    
                }
                
                var picker = CTAssetsPickerController()
                picker.delegate = self
                //self.presentViewController(picker, animated: true, completion: nil)
                
                
                // create options for fetching photo only
                var fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)

                // assign options
                picker.assetsFetchOptions = fetchOptions;

                // set default album (Camera Roll)
                picker.defaultAssetCollection = PHAssetCollectionSubtype.SmartAlbumUserLibrary
                
                // hide cancel button;
                // picker.showsCancelButton = false
                
                // make done button enable even without selection
                picker.alwaysEnableDoneButton = true
                
                // present picker
                self.presentViewController(picker, animated: true, completion: nil)
            }
        }

    }
}

extension AlbumViewController : CTAssetsPickerControllerDelegate {
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        
        // If no photos were selected, dismiss CTAssetsPickerController
        if assets.count == 0 {
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        // If photos were selected, check for the method of sending
        else {
            if let zapBool = zapBool {
                
                //transaction = Transaction()
                
                //picker.dismissViewControllerAnimated(true, completion: nil)
                //transaction!.assets = assets
                //self.assets = assets
                
                picker.dismissViewControllerAnimated(true, completion: nil)
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Do Wi-Fi Direct
                if zapBool {
                    let nearbyFriends = mainStoryboard.instantiateViewControllerWithIdentifier("NearbyFriendsNavigation") as! UINavigationController
                    (nearbyFriends.visibleViewController as! NearbyFriendsViewController).assets = assets
                    self.presentViewController(nearbyFriends, animated: true, completion: nil)
                    
                    //self.performSegueWithIdentifier("NearbyFriendsNavigation", sender: self)
                }
                // Do Wi-Fi Delay
                else {
                    //let chooseFriends = mainStoryboard.instantiateViewControllerWithIdentifier("ChooseFriendsNavigation") as! UINavigationController
                    let chooseFriends = mainStoryboard.instantiateViewControllerWithIdentifier("ChooseFriendsNavigation") as! UINavigationController
                    (chooseFriends.visibleViewController as! ChooseFriendsViewController).assets = assets
                    self.presentViewController(chooseFriends, animated: true, completion: nil)
                    //(chooseFriends.visibleViewController as! ChooseFriendsViewController).picker = picker
                    //picker.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        // tableView.reloadData
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: PHAsset!) -> Bool {
        let max = 10
        
        if picker.selectedAssets.count >= max {
            var alert = UIAlertController(title: "Attention", message: "Please select not more than \(max) assets", preferredStyle: .Alert)
            var action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(action)
            picker.presentViewController(alert, animated: true, completion: nil)
        }
        
        return picker.selectedAssets.count < max
    }
}
