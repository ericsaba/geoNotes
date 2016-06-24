//
//  ListNoteViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 4/17/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class ListNoteViewController: UIViewController {
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()
        if note != nil {
            switch note!.type! {
            case "anon":
                self.navigationController?.navigationBar.barTintColor = ACCENT_COLOR
            case "personal":
                self.navigationController?.navigationBar.barTintColor = PERSONAL_COLOR
            case "scenery":
                self.navigationController?.navigationBar.barTintColor = SCENERY_COLOR
            case "restaurant":
                self.navigationController?.navigationBar.barTintColor = RESTAURANT_COLOR
            case "caution":
                self.navigationController?.navigationBar.barTintColor = CAUTION_COLOR
            default:
                self.navigationController?.navigationBar.barTintColor = ACCENT_COLOR
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller: NoteViewController = storyboard.instantiateViewControllerWithIdentifier("NoteViewController") as! NoteViewController
            controller.note = note
            controller.view.frame = CGRect(x: 0.0, y: (self.navigationController?.navigationBar.frame.height)! + 20.0, width: self.view.frame.width, height: self.view.frame.height - (self.navigationController?.navigationBar.frame.height)! - 20.0)
            self.view.addSubview(controller.view)
            self.addChildViewController(controller)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
