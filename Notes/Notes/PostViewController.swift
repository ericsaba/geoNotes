//
//  PostViewController.swift
//  Notes
//
//  Created by Eric Saba on 1/25/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit
import CoreLocation

class PostViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: UITextView!
    let iconsArray: [String] = ["anonicon", "personalicon", "sceneryicon", "restauranticon", "cautionicon"]
    var buttons: [UIButton] = []
    var lat: Double = 0
    var long: Double = 0
    var selected: String = "anon"
    var selectFriendsController: SelectFriendsTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = ACCENT_COLOR
        
        containerView.hidden = true
        
        textView.layer.borderColor = ACCENT_COLOR.CGColor
        textView.layer.borderWidth = 1.5
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        
        scrollView.frame = CGRect(x: 0.0, y: scrollView.frame.origin.y, width: self.view.frame.width, height: scrollView.frame.height)
        
        if (lat == 0 && long == 0) {
            print("Location services not enabled.")
        }
        
        var buffer: CGFloat = 5.0
        var width: CGFloat = CGFloat(iconsArray.count)*TYPE_SIZE + 5.0*CGFloat(iconsArray.count)
        if width < scrollView.frame.width {
            width = scrollView.frame.width
            buffer = (width - 10.0 - CGFloat(iconsArray.count)*TYPE_SIZE) / CGFloat(iconsArray.count)
        }
        scrollView.contentSize = CGSizeMake(width - buffer, TYPE_SIZE + 10.0)
        scrollView.scrollEnabled = true
        
        for i in 0...iconsArray.count-1 {
            let curButton = UIButton(frame: CGRect(x: 5.0 + CGFloat(i) * (TYPE_SIZE + buffer), y: 5.0, width: TYPE_SIZE, height: TYPE_SIZE))
            curButton.layer.cornerRadius = 5
            curButton.clipsToBounds = true
            curButton.layer.borderColor = ACCENT_COLOR.CGColor
            curButton.setImage(UIImage(named: iconsArray[i]), forState: UIControlState.Normal)
            curButton.addTarget(self, action: #selector(PostViewController.buttonPressed(_:)), forControlEvents: .TouchUpInside)
            buttons.append(curButton)
            scrollView.addSubview(curButton)
        }
        
        buttons[0].layer.borderColor = UIColor.blackColor().CGColor
        buttons[0].layer.borderWidth = 1.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendPushed(sender: AnyObject) {
        if selected == "personal" {
            if selectFriendsController != nil {
                var usernames: [String] = []
                for con in selectFriendsController!.selected {
                    usernames.append((con.user?.username)!)
                }
                CallHandler().postPersonal(textView.text!, lat: lat, long: long, forUsers: usernames)
            }
        } else {
            CallHandler().postAnon(textView.text!,lat: lat,long: long, type: selected)
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    @IBAction func cancelPushed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func buttonPressed(sender: AnyObject) {
        let curButton = sender as! UIButton
        for i in 0...buttons.count - 1 {
            let button = buttons[i]
            button.layer.borderWidth = 0.0
            if (button.isEqual(curButton)) {
                selected = iconsArray[i].componentsSeparatedByString("icon")[0]
            }
            if selected == "personal" {
                containerView.hidden = false
            }
            else {
                containerView.hidden = true
            }
        }
        curButton.layer.borderWidth = 1.5
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ContainerSegue" {
            selectFriendsController = segue.destinationViewController as? SelectFriendsTableViewController
        }
    }

}
