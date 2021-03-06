//
//  AddFriendTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/14/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

protocol AddFriendTableViewCellDelegate: class {
    func cell(cell: AddFriendTableViewCell, didSelectFriendUser user: PFUser)
    func cell(cell: AddFriendTableViewCell, didSelectUnfriendUser user: PFUser)
}

class AddFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    weak var delegate: AddFriendTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
        }
    }
    
    var canFriend: Bool? = true {
        didSet {
            /*
            Change the state of the friend button based on whether or not
            it is possible to friend request a user.
            */
            
            if let canFriend = canFriend {
                friendButton.selected = !canFriend
            }
        }
    }
    
    var alreadyFriends: Bool? = false {
        didSet {
            /*
            Change the state of the friend button based on whether or not
            the current user is already friends with the displayed user.
            */
            if user?.username == PFUser.currentUser()!.username {
                friendButton.enabled = false
            } else if let alreadyFriends = alreadyFriends {
                friendButton.enabled = !alreadyFriends
            }
            
        }
    }
    

    @IBAction func friendButtonTapped(sender: AnyObject) {
        
        if let canFriend = canFriend where canFriend == true {
            delegate?.cell(self, didSelectFriendUser: user!)
            self.canFriend = false
        } else {
            delegate?.cell(self, didSelectUnfriendUser: user!)
            self.canFriend = true
        }
    }

}
