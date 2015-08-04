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

class AlbumViewController: UIViewController, CTAssetsPickerControllerDelegate {
    
    //var assets : [AnyObject] = []
    var transaction : Transaction?
    var zapBool : Bool?
    
    /*
    var freshLaunch = true
    override func viewWillAppear(animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
            self.tabBarController!.selectedIndex = 1 // 2nd tab
        }
    } */

    override func viewDidLoad() {
        super.viewDidLoad()

    }
  /*
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        nearbyFriends = NearbyFriendsViewController()
    } */
    
    @IBAction func zapButtonTapped(sender: AnyObject) {
        zapBool = true
        
        let alertController = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .ActionSheet)
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
        zapBool = false
        showAlbum()
    }
    
    
    func showAlbum() {
        
        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue()) {
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
                
                transaction = Transaction()
                
                picker.dismissViewControllerAnimated(true, completion: nil)
                transaction!.assets = assets
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Do Wi-Fi Direct
                if zapBool {
                    let nearbyFriends = mainStoryboard.instantiateViewControllerWithIdentifier("NearbyFriendsNavigation") as! UINavigationController
                    (nearbyFriends.visibleViewController as! NearbyFriendsViewController).transaction = transaction
                    self.presentViewController(nearbyFriends, animated: true, completion: nil)
                    //self.performSegueWithIdentifier("NearbyFriendsNavigation", sender: self)
                }
                // Do Wi-Fi Delay
                else {
                    let chooseFriends = mainStoryboard.instantiateViewControllerWithIdentifier("ChooseFriendsNavigation") as! UINavigationController
                    self.presentViewController(chooseFriends, animated: true, completion: nil)
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
