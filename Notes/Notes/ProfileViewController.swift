//
//  ProfileViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 3/4/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    var tfs: [UITextField] = []
    var editable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tfs = [usernameTF, phoneTF, emailTF]
        resetUserFields()
        logOutButton.setTitleColor(ACCENT_COLOR, forState: UIControlState.Normal)
        // Do any additional setup after loading the view.
    }
    
    func resetUserFields() {
        if let user = PFUser.currentUser() {
            usernameTF.text = user.username
            if let num = user["phoneNumber"] as? String {
                if num != "" {
                    phoneTF.text = num
                }
            }
            if let email = user.email {
                if email != "" {
                    emailTF.text = email
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutPressed(sender: AnyObject) {
        PFUser.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editable
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func barButtonPressed(sender: UIBarButtonItem) {
        if editable {
            let user = PFUser.currentUser()
            //save
            sender.title = "Edit"
            for tf in tfs {
                tf.resignFirstResponder()
                tf.textColor = UIColor.blackColor()
            }
            user?.username = usernameTF.text
            user!["phoneNumber"] = phoneTF.text
            if emailTF.text != "" {
                user?.email = emailTF.text
            }
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if success {
                    self.editable = false
                }
                else {
                    let alert = UIAlertController(title: error?.localizedDescription, message: error?.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                    }))
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                    })
                    self.resetUserFields()
                }
            })
        }
        else {
            //edit mode
            editable = true
            sender.title = "Save"
            for tf in tfs {
                tf.textColor = ACCENT_COLOR
            }
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
