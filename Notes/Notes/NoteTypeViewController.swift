//
//  NoteTypeViewController.swift
//  geoNotes
//
//  Created by Eric Saba on 3/1/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

protocol TypeDelegateProtocol {
    func setType(type: String)
}

class NoteTypeViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    let iconsArray: [String] = ["anonicon", "personalicon", "sceneryicon", "restauranticon", "cautionicon"]
    var buttons: [UIButton] = []
    var delegate: TypeDelegateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(CGFloat(iconsArray.count)*TYPE_SIZE + 5.0*CGFloat(iconsArray.count), TYPE_SIZE + 10.0)
        scrollView.scrollEnabled = true
        
        for i in 0...iconsArray.count-1 {
            let curButton = UIButton(frame: CGRect(x: 5.0 + CGFloat(i) * (TYPE_SIZE + 5.0), y: 5.0, width: TYPE_SIZE, height: TYPE_SIZE))
            curButton.layer.cornerRadius = 5
            curButton.clipsToBounds = true
            curButton.setImage(UIImage(named: iconsArray[i]), forState: UIControlState.Normal)
            curButton.addTarget(self, action: #selector(NoteTypeViewController.buttonPressed(_:)), forControlEvents: .TouchUpInside)
            buttons.append(curButton)
            scrollView.addSubview(curButton)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonPressed(sender: AnyObject) {
        let curButton = sender as! UIButton
        var index = 0
        for i in 0...buttons.count - 1 {
            let button = buttons[i]
            if curButton.isEqual(button) {
                index = i
                break
            }
        }
        dismissViewControllerAnimated(true) { () -> Void in
            self.delegate?.setType(self.iconsArray[index])
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
