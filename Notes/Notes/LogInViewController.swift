//
//  LogInViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 2/29/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ACCENT_COLOR
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        logInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        CallHandler().getLatestUpdate { (success, update, updatesObj) in
            if success == true {
                if update.seen == false {
                    let alert = UIAlertController(title: update.title, message: update.desc, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                        CallHandler().addSeenToUpdate(updatesObj)
                        self.checkLogIn()
                    }))
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                    })
                } else {
                    self.checkLogIn()
                }
            }
            else {
                print("Could not get updates.")
                self.checkLogIn()
            }
        }
    }
    
    func checkLogIn() {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            self.performSegueWithIdentifier("LogInSegue", sender: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(sender: AnyObject) {
        usernameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        PFUser.logInWithUsernameInBackground(usernameTF.text!, password: passwordTF.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("LogInSegue", sender: self)
            } else {
                let errorString = error!.userInfo["error"] as! String
                let alert = UIAlertController(title: "Log in failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                })
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
