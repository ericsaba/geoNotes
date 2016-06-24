//
//  SelectFriendsTableViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 4/3/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class SelectFriendsTableViewController: UITableViewController {
    var model: FriendsModel?
    var selected: [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        model = FriendsModel(tableView: self.tableView, curUser: PFUser.currentUser()!)
        model?.getData()
    }
    
    override func viewDidAppear(animated: Bool) {
        selected = []
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (model?.currentFriends.count)!
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectFriendCell", forIndexPath: indexPath)
        cell.textLabel?.text = model?.currentFriends[indexPath.row].name
        cell.detailTextLabel?.text = model?.currentFriends[indexPath.row].user!.username
        cell.accessoryView = UIImageView(image: UIImage(named: "addicon"))
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if selected.contains((model?.currentFriends[indexPath.row])!) {
            selected.removeAtIndex(selected.indexOf((model?.currentFriends[indexPath.row])!)!)
            cell?.accessoryView = UIImageView(image: UIImage(named: "addicon"))
        }
        else {
            selected.append((model?.currentFriends[indexPath.row])!)
            cell?.accessoryView = UIImageView(image: UIImage(named: "checkicon"))
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }

}
