//
//  AddFriendViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/14/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse

class AddFriendViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    // stores all the users that match the current search query
    var users: [PFUser]?
    
    /*
        This is a local cache. It stores all the users this user is friends with.
        It is used to update the UI immediately upon user interaction instead of waiting
        for a server response.
    */
    
    var friendUsers: [PFUser]? {
        didSet {
            /**
            the list of following users may be fetched after the tableView has displayed
            cells. In this case, we reload the data to reflect "following" status
            */
            tableView.reloadData()
        }
    }
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // this view can be in two different states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
            }
        }
    }
    
    // MARK: Update userList
    
    /** 
        Is called as the completion block of all queries.
        As soon as a query completes, this method updates the Table View.
    */
    func updateList(results: [AnyObject]?, error: NSError?) {
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
        /*
        if let error = error {
            ErrorHandling.defaultErrorHandler(error)
        }
        */
    }

    
    // MARK: View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .DefaultMode
        
        // fill the cache of a user's friends
        ParseHelper.getFriendUsersForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            // use map to extract the User from a Friend Object
            self.friendUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendToUser) as! PFUser
            }
            
            /*
            if let error = error {
                // Call the default error handler in case of an error
                ErrorHandling.defaultErrorHandler(error)
            }
            */
        }
        //Error here?
    }
    

}

// MARK: TableView Data Source

extension AddFriendViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddFriendCell") as! AddFriendTableViewCell
        
        let user = users![indexPath.row]
        cell.user = user
        
        if let friendUsers = friendUsers {
            // check if current user is already friends with displayed user
            // change button appearance based on result
            cell.canFriend = !contains(friendUsers, user)
        }
        
        cell.delegate = self
        return cell
    }

}

// MARK: Searchbar Delegate

extension AddFriendViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText, completionBlock: updateList)
    }
}

// MARK: AddFriendTableViewCell Delegate

extension AddFriendViewController: AddFriendTableViewCellDelegate {
    
    func cell(cell: AddFriendTableViewCell, didSelectFriendUser user: PFUser) {
        ParseHelper.addFriendRelationshipFromUser(PFUser.currentUser()!, toUser: user)
        //update local cache
        friendUsers?.append(user)
    }
    
    func cell(cell: AddFriendTableViewCell, didSelectUnfriendUser user: PFUser) {
        if var friendUsers = friendUsers {
            ParseHelper.removeFriendRelationshipFromUser(PFUser.currentUser()!, toUser: user)
            //update local cache
            removeObjectFromArray(user, &friendUsers)
        
            self.friendUsers = friendUsers
        }
    }
}
/*
public func removeObjectFromArray<T : Equatable>(object: T, inout array: [T])
{
    var index = find(array, object)
    array.removeAtIndex(index!)
}

public func removeObject(object: T) {
    removeObjectFromArray(object, &self.content)
    currentRange.endIndex = self.currentRange.endIndex - 1
    target?.tableView.reloadData()
}
*/

