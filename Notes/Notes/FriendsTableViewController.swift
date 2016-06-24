//
//  FriendsTableViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 3/27/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit
import MessageUI
import Contacts

class FriendsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    var model: FriendsModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.currentUser()!["phoneNumber"] as! String == "" {
            let alert = UIAlertController(title: "Add Phone Number First", message: "Please add your phone number to your profile in Settings so your friends can find you!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: { () -> Void in
            })
        }
        model = FriendsModel(tableView: self.tableView, curUser: PFUser.currentUser()!)
        model?.getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (model?.currentFriends.count)!
        }
        else if section == 1 {
            return (model?.potentialFriends.count)!
        }
        else if section == 2 {
            return (model?.contacts.count)!
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendsCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = model?.currentFriends[indexPath.row].name
            cell.detailTextLabel?.text = model?.currentFriends[indexPath.row].user!.username
            cell.accessoryView = UIImageView()
        }
        else if indexPath.section == 1 {
            cell.detailTextLabel?.text = model!.potentialFriends[indexPath.row].user!.username
            cell.textLabel?.text = model!.potentialFriends[indexPath.row].name
            if model?.potentialFriends[indexPath.row].requested == true {
                cell.accessoryView = UIImageView(image: UIImage(named: "checkicon"))
            } else {
                cell.accessoryView = UIImageView(image: UIImage(named: "addicon"))
            }
        }
        else {
            cell.textLabel?.text = String(format: "%@ %@", arguments: [model!.contacts[indexPath.row].givenName, model!.contacts[indexPath.row].familyName])
            cell.detailTextLabel?.text = ""
            cell.accessoryView = UIImageView(image: UIImage(named: "mailicon"))
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Friends"
        }
        else if section == 1 {
            return "Add Friends"
        }
        else {
            return "Invite Friends"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.section == 0 {
            
        }
        else if indexPath.section == 1 {
            cell!.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 24.0, height: 24.0))
            let activityView = UIActivityIndicatorView(frame: (cell?.accessoryView!.frame)!)
            cell?.accessoryView?.addSubview(activityView)
            activityView.color = ACCENT_COLOR
            activityView.startAnimating()
            CallHandler().postFollow(PFUser.currentUser()!, toUser: (model?.potentialFriends[indexPath.row].user)!, completion: { (success, friends) in
                activityView.stopAnimating()
                if success == true {
                    if friends == true {
                        self.model?.currentFriends.append((self.model?.potentialFriends.removeAtIndex(indexPath.row))!)
                    }
                    else {
                        self.model?.potentialFriends[indexPath.row].requested = true
                    }
                }
                self.tableView.reloadData()
            })
        }
        else {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Check out this super cool and fun app I found called geoNotes! https://geo.itunes.apple.com/us/app/geonotes/id1086191459?mt=8"
            messageVC.recipients = []
            if ((model?.contacts[indexPath.row].isKeyAvailable(CNContactPhoneNumbersKey)) != nil) {
                for phoneNumber:CNLabeledValue in (model?.contacts[indexPath.row].phoneNumbers)! {
                    let a: String = (phoneNumber.value as! CNPhoneNumber).stringValue
                    if a.characters.count >= 12 {
                        messageVC.recipients?.append(a)
                        break
                    }
                }
            }
            messageVC.messageComposeDelegate = self
            
            self.presentViewController(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }

}
