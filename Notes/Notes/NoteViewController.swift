//
//  NoteViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 4/10/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    var deleteButton: UIButton?
    
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        usernameLabel.text = ""
        if note != nil {
            directionLabel.text = String(format: "%@ yards %@", note!.getDistText(), note!.getDirText())
            
            noteTextView.text = note?.text
            noteTextView.layer.borderColor = ACCENT_COLOR.CGColor
            noteTextView.layer.borderWidth = 1.5
            noteTextView.layer.cornerRadius = 5
            noteTextView.clipsToBounds = true
            note?.setNoteUsername({ (reload, selfPosted) in
                if reload {
                    if selfPosted {
                        self.usernameLabel.text = "- you"
                        self.usernameLabel.textColor = ACCENT_COLOR
                        self.createDeleteButton()
                    }
                    else {
                        self.usernameLabel.text = String(format: "-%@", (self.note?.username)!)
                    }
                }
            })
        }
    }
    
    func createDeleteButton() {
        deleteButton = UIButton(frame: CGRect(x: self.view.frame.width - 40.0, y: self.view.frame.height - 40.0, width: BUTTON_SIZE / 2, height: BUTTON_SIZE / 2))
        deleteButton!.setImage(UIImage(named: "trash_button"), forState: .Normal)
        deleteButton!.addTarget(self, action: #selector(NoteViewController.deleteNote(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(deleteButton!)
    }
    
    func deleteNote(sender: UIButton) {
        let alert = UIAlertController(title: "Delete note?", message: "Are you sure you want to delete this note?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (UIAlertAction) -> Void in
            self.note?.noteObj?.deleteInBackground()
            self.dismissViewControllerAnimated(true, completion: { 
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) in
        }))
        self.presentViewController(alert, animated: true, completion: { () -> Void in
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        noteTextView.setContentOffset(CGPointZero, animated: false)
        deleteButton?.frame = CGRect(x: self.view.frame.width - 40.0, y: self.view.frame.height - 40.0, width: BUTTON_SIZE / 2, height: BUTTON_SIZE / 2)
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
