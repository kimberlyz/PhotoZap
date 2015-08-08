//
//  MPCManager.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/31/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import ConvenienceKit

protocol MPCManagerDelegate {
    func invitationWasReceived(fromPeer: String)
    func refreshConnectionStatus()
    func photoWasReceived(image: UIImage, fromPeer: MCPeerID)
}



class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    var foundPeers = [MCPeerID]()
    var connectedPeers = [MCPeerID]()
    var invitationHandler : ((Bool, MCSession!) -> Void)!
    var delegate : MPCManagerDelegate?
    
    //let mySpecialNotificationKey = "pieandpudding.specialNotificationKey"
    
    override init() {
        super.init()
        
        // make the displayName your username in the future
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "PhotoZap-mpc12")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "PhotoZap-mpc12")
        advertiser.delegate = self

    }
    /*
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        NSNotificationCenter.defaultCenter().postNotificationName("MPCReceivingProgressNotification", object: nil, userInfo: ["progress" : object])
    } */
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        foundPeers.append(peerID)
        println("Found Peer on receiving end")
        println(foundPeers)
        delegate?.refreshConnectionStatus()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        for (index, aPeer) in enumerate(foundPeers) {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        delegate?.refreshConnectionStatus()
    }
    
    // If browsing is unable to be performed
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("received invitation")
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println(error.localizedDescription)
    }
}

extension MPCManager: MCSessionDelegate {
    
    /** Called when a user connects or disconnects from our session
    Is someone connecting, are they now connected, or have they just disconnected?
    */
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        switch state {
            
        case MCSessionState.Connected:
            println("Connected: \(peerID.displayName)")
            connectedPeers.append(peerID)
            delegate?.refreshConnectionStatus()

        case MCSessionState.Connecting:
            println("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            println("Not Connected: \(peerID.displayName)")
            println(connectedPeers)
            if connectedPeers.count != 0 {
                removeObjectFromArray(peerID, &connectedPeers)
            }
            delegate?.refreshConnectionStatus()
        }
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let image = UIImage(data: data) {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                delegate?.photoWasReceived(image, fromPeer: peerID)
//                self.friendPeerID = peerID
//                self.images.insert(image, atIndex: 0)
//                self.tableView.reloadData()
            }
            
        }
    }
    
    /*
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    } */
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        /*
        println("Started Receiving Resource")
       // NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
        var dict: [String: AnyObject] = ["resourceName" : resourceName, "peerID" : peerID, "progress" : progress]
        
        //NSNotificationCenter.defaultCenter().postNotificationName(mySpecialNotificationKey, object: self)
        
        NSNotificationCenter.defaultCenter().postNotificationName("MPCDidStartReceivingResourceNotification", object: nil, userInfo: dict)
        dispatch_async(dispatch_get_main_queue()) { // 2
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.New, context: nil)
        } */
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
        /*
        println("Finished Receiving Resource")
        var dict: [String: AnyObject] = ["resourceName" : resourceName, "peerID" : peerID, "localURL" : localURL]
        
        NSNotificationCenter.defaultCenter().postNotificationName("didFinishReceivingResourceNotification", object: nil, userInfo: dict) */
    }
    
}