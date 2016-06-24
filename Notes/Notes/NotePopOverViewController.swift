//
//  NotePopOverViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 4/13/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class NotePopOverViewController: UIViewController {
    let TYPE_VIEW_HEIGHT: CGFloat = 44.0
    var typeView: UIView?
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()
        typeView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: TYPE_VIEW_HEIGHT))
        let closeButton = UIButton(frame: CGRect(x: typeView!.frame.width - 75.0, y: TYPE_VIEW_HEIGHT / 2 - 15.0, width: 30.0, height: 30.0))
        closeButton.setTitle("X", forState: .Normal)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.addTarget(self, action: #selector(NotePopOverViewController.closePressed), forControlEvents: .TouchUpInside)
        typeView?.addSubview(closeButton)
        typeView?.bringSubviewToFront(closeButton)
        
        self.view.addSubview(typeView!)
        
        switch note!.type! {
        case "anon":
            typeView!.backgroundColor = ACCENT_COLOR
        case "personal":
            typeView!.backgroundColor = PERSONAL_COLOR
        case "scenery":
            typeView!.backgroundColor = SCENERY_COLOR
        case "restaurant":
            typeView!.backgroundColor = RESTAURANT_COLOR
        case "caution":
            typeView!.backgroundColor = CAUTION_COLOR
        default:
            typeView!.backgroundColor = ACCENT_COLOR
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller: NoteViewController = storyboard.instantiateViewControllerWithIdentifier("NoteViewController") as! NoteViewController
        controller.note = note
        controller.view.frame = CGRect(x: 0.0, y: typeView!.frame.height, width: self.view.frame.width, height: self.view.frame.height - typeView!.frame.height)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closePressed() {
        dismissViewControllerAnimated(true) {
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
