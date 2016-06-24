//
//  MapSettingsViewController.swift
//  Notes
//
//  Created by Eric Saba on 2/14/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit
import GoogleMaps

class MapSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var pickerView: UIPickerView!
    var mapVC: MapViewController = MapViewController()
    
    let options = ["Satellite", "Hybrid", "Normal"]

    override func viewDidLoad() {
        super.viewDidLoad()
        for vc in (self.navigationController?.viewControllers)! {
            if vc.isMemberOfClass(MapViewController) {
                mapVC = vc as! MapViewController
                break
            }
        }
        pickerView.reloadAllComponents()
        pickerView.selectRow(options.indexOf(mapVC.mapType)!, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UIPickerView
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return options.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: options[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        do {
            mapVC.setMapStyle(options[row])
            PFUser.currentUser()!["mapType"] = options[row]
            try PFUser.currentUser()!.save()
        } catch {
            let alert = UIAlertController(title: "Error", message: "Could not update settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                pickerView.selectRow(self.options.indexOf(self.mapVC.mapType)!, inComponent: 0, animated: true)
                PFUser.currentUser()!["mapType"] = self.mapVC.mapType
            })
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
