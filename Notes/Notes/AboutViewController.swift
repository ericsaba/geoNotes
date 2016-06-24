//
//  AboutViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 2/29/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var surveyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        surveyButton.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func surveyPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://docs.google.com/forms/d/1qS6B86y0fVg8JKUUrMuHGl-rDavqMCLMGpwvLPoaU1Q/viewform")!)
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
