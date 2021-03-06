//
//  FriendListTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/14/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class FriendListTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: PFUser? {
        didSet {
            if let user = user {
                user.fetchIfNeededInBackgroundWithBlock({ (userObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        ParseErrorHandlingController.handleParseError(error!)
                    } else {
                        let userPFObject = userObject as! PFUser
                        self.usernameLabel.text = userPFObject["username"] as? String
                    }
                })
            }
        }
    }
}
