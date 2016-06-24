//
//  ListTableViewController.swift
//  Notes
//
//  Created by Eric Saba on 1/31/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    var userLat: Double = 0.0
    var userLong: Double = 0.0
    var notes: [Note] = []
    var curViewNote: Note?
    let typeDict: Dictionary<String, UIImage> = ["anon" : UIImage(named: "anonicon")!,
                                "personal" : UIImage(named: "personalicon")!,
                                "scenery" : UIImage(named: "sceneryicon")!,
                                "restaurant" : UIImage(named: "restauranticon")!,
                                "caution" : UIImage(named: "cautionicon")!]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = ACCENT_COLOR
        getData()
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = ACCENT_COLOR
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getData() {
        CallHandler().getAllNotes(userLat, long: userLong) { (success, dict) in
            if success {
                for value in dict.values {
                    for note in value {
                        if note.dist <= FIND_RADIUS {
                            self.notes.append(note)
                        }
                    }
                }
                self.notes.sortInPlace({ (this: Note, that: Note) -> Bool in
                    if this.dist > that.dist {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableView.reloadData()
                for note in self.notes {
                    note.setNoteUsername({ (reload, selfPosted) in
                        if reload {
                            self.tableView.reloadData()
                        }
                    })
                }
            }
            else {
                //handle error
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as! CustomTableViewCell
        let note = notes[indexPath.row]
        cell.distanceLabel.text = note.getDistText()
        if note.username != "" {
            if note.username == PFUser.currentUser()?.username {
                cell.usernameLabel.text = "- you"
                cell.usernameLabel.textColor = ACCENT_COLOR
            }
            else {
                cell.usernameLabel.text = String(format: "- %@", note.username)
                cell.usernameLabel.textColor = UIColor.blackColor()
            }
        }
        else {
            cell.usernameLabel.text = ""
            cell.usernameLabel.textColor = UIColor.blackColor()
        }
        cell.directionLabel?.text = note.getDirText()
        cell.textView?.text = note.text
        cell.iconImageView.image = typeDict[note.type!]
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 84.0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 84.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        curViewNote = notes[indexPath.row]
        self.performSegueWithIdentifier("ListNoteViewSegue", sender: self)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */



    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ListNoteViewSegue" {
            let listNoteVC: ListNoteViewController = segue.destinationViewController as! ListNoteViewController
            listNoteVC.note = curViewNote
        }
    }
}
