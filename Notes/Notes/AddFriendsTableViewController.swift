//
//  AddFriendsTableViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 3/20/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class AddFriendsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    var curUser: PFUser = PFUser()
    var model: FriendsModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        model = FriendsModel(tableView: self.tableView, curUser: curUser)
        model?.getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return model!.potentialFriends.count
        } else {
            return model!.contacts.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("addFriendsCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell.detailTextLabel?.text = model!.potentialFriends[indexPath.row].user?.username
            cell.textLabel?.text = model!.potentialFriends[indexPath.row].name
            if model?.potentialFriends[indexPath.row].requested == true {
                cell.accessoryView = UIImageView(image: UIImage(named: "checkicon"))
                
            }
            else {
                cell.accessoryView = UIImageView(image: UIImage(named: "addicon"))
            }
        } else {
            cell.textLabel?.text = String(format: "%@ %@", arguments: [model!.contacts[indexPath.row].givenName, model!.contacts[indexPath.row].familyName])
            cell.detailTextLabel?.text = ""
            cell.accessoryView = UIImageView(image: UIImage(named: "mailicon"))
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Add Friends"
        }
        else {
            return "Invite Friends"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if model?.potentialFriends[indexPath.row].requested == true {
                model?.potentialFriends[indexPath.row].requested = false
                cell?.accessoryView = UIImageView(image: UIImage(named: "checkicon"))
            }
            else {
                cell?.accessoryView = UIImageView(image: UIImage(named: "addicon"))
                model?.potentialFriends[indexPath.row].requested = true
            }
            tableView.reloadData()
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

    @IBAction func signUpPressed(sender: UIBarButtonItem) {
        CallHandler().signUpUser(self.curUser, completion: { (success, errorString) in
            if success == true {
                for contact in self.model!.potentialFriends {
                    if contact.requested {
                        CallHandler().postFollow(self.curUser, toUser: contact.user!)
                    }
                }
                self.performSegueWithIdentifier("AddFriendsLogInSegue", sender: self)
            } else {
                let alert = UIAlertController(title: "Log in failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                })
            }
        })
        
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
            break;
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
