//
//  SignUpViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 2/29/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confPasswordTF: UITextField!
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var signUpButton: UIBarButtonItem!
    var segueIdentifier: String = "SignUpLogInSegue"
    var array: [UITextField] = []
    var curUser: PFUser = PFUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        array = [usernameTF, passwordTF, confPasswordTF, phoneNumTF]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = ACCENT_COLOR
        for tf in array {
            tf.layer.borderColor = ACCENT_COLOR.CGColor
            tf.layer.borderWidth = 1.5
            tf.layer.cornerRadius = 5
            tf.clipsToBounds = true
        }
        phoneNumTF.addTarget(self, action: #selector(SignUpViewController.phoneNumberChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func phoneNumberChanged(textField: UITextField) {
        if textField.text != "" {
            signUpButton.title = "Add Friends"
            segueIdentifier = "AddFriendsSegue"
        }
        else {
            signUpButton.title = "Sign Up"
            segueIdentifier = "SignUpLogInSegue"
        }
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        var check = true
        for tf in array {
            tf.resignFirstResponder()
            if tf.text == "" && !tf.isEqual(phoneNumTF) {
                tf.layer.borderColor = UIColor.redColor().CGColor
                check = false
            }
        }
        if check == false {
            let alert = UIAlertController(title: "Fields left empty", message: "Please fill out all of the fields above.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                        }))
            self.presentViewController(alert, animated: true, completion: { () -> Void in
            })
        }
        else {
            if passwordTF.text != confPasswordTF.text {
                check = false
                let alert = UIAlertController(title: "Passwords do not match.", message: "Please make sure your passwords match.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                })
            }
            if check == true {
                let user = PFUser()
                user.username = usernameTF.text
                user.password = passwordTF.text
                user["mapType"] = "Satellite"
                user["admin"] = false
                if phoneNumTF.text != "" {
                    user["phoneNumber"] = phoneNumTF.text
                }
                self.curUser = user
                if (self.segueIdentifier == "SignUpLogInSegue") {
                    CallHandler().signUpUser(user, completion: { (success, errorString) in
                        if (success == true) {
                            self.performSegueWithIdentifier(self.segueIdentifier, sender: self)
                        }
                        else {
                            let alert = UIAlertController(title: "Log in failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                            }))
                            self.presentViewController(alert, animated: true, completion: { () -> Void in
                            })
                        }
                    })
                }
                else {
                    self.performSegueWithIdentifier(self.segueIdentifier, sender: self)
                }
            }
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignUpLogInSegue" {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else if segue.identifier == "AddFriendsSegue" {
            let addVC = segue.destinationViewController as! AddFriendsTableViewController
            addVC.curUser = self.curUser
        }
    }


}
