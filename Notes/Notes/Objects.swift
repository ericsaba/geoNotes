//
//  Objects.swift
//  Notes
//
//  Created by Eric Saba on 1/31/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import Foundation
import MapKit
import QuartzCore

let ACCENT_COLOR: UIColor = UIColor(red: 14.0 / 255, green: 127.0 / 255, blue: 255.0 / 255, alpha: 1.0)
let SCENERY_COLOR: UIColor = UIColor(red: 12.0 / 255, green: 208.0 / 255, blue: 0, alpha: 1.0)
let CAUTION_COLOR: UIColor = UIColor(red: 255.0 / 255, green: 5.0 / 255, blue: 34.0 / 255, alpha: 1.0)
let PERSONAL_COLOR: UIColor = UIColor(red: 130.0 / 255, green: 52.0 / 255, blue: 255.0 / 255, alpha: 1.0)
let RESTAURANT_COLOR: UIColor = UIColor(red: 255.0 / 255, green: 255.0 / 255, blue: 0, alpha: 1.0)
let FIND_RADIUS: Double = 50.0
let CAMERA_ZOOM: Float = 19.8
let BUTTON_SIZE: CGFloat = 60.0
let TYPE_SIZE: CGFloat = 40.0
let Y_INSET: CGFloat = 80.0
let POPOVER_INSET: CGFloat = 20.0

class Note: NSObject {
    var noteObj: PFObject?
    var lat: Double?
    var long: Double?
    var text: String?
    var dist: Double?
    var dir: Double?
    var image: UIImage?
    var type: String?
    var username: String = ""
    
    init(noteObj: PFObject, userLat: Double, userLong: Double) {
        super.init()
        self.noteObj = noteObj
        lat = (noteObj.objectForKey("location") as! PFGeoPoint).latitude
        long = (noteObj.objectForKey("location") as! PFGeoPoint).longitude
        text = noteObj.objectForKey("note") as? String
        type = noteObj.objectForKey("type") as? String
        dist = CallHandler().findDistance(userLat, long1: userLong, lat2: lat!, long2: long!)
        dir = CallHandler().findDirection(userLat, long1: userLong, lat2: lat!, long2: long!)
        
    }
    
    func setNoteUsername(completion: (reload: Bool, selfPosted: Bool) -> Void) {
        if username == "" {
            CallHandler().getUserForNote(self.noteObj!, completion: { (success, username) in
                if success {
                    if self.type == "personal" {
                        self.username = username
                        completion(reload: true, selfPosted: false)
                    }
                    else if username == PFUser.currentUser()?.username {
                        self.username = username
                        completion(reload: true, selfPosted: true)
                    }
                    else {
                        completion(reload: false, selfPosted: false)
                    }
                }
                else {
                    completion(reload: false, selfPosted: false)
                }
            })
        }
        else {
            if self.username == PFUser.currentUser()?.username {
                completion(reload: true, selfPosted: true)
            }
            else {
                completion(reload: true, selfPosted: false)
            }
        }
    }
    
//    init(note: String, latitude: Double, longitude: Double, userLat: Double, userLong: Double, noteType: String) {
//        super.init()
//        text = note
//        lat = latitude
//        long = longitude
//        dist = CallHandler().findDistance(userLat, long1: userLong, lat2: latitude, long2: longitude)
//        dir = CallHandler().findDirection(userLat, long1: userLong, lat2: latitude, long2: longitude)
//        type = noteType
//    }
    
    func getDistText() -> String {
        return String(format: "%.0f", dist!)
    }
    
    func getDirText() -> String {
        var ret = ""
        if (dir > 292.5 || dir <= 67.5) {
            ret.appendContentsOf("N")
        }
        if (dir > 112.5  && dir <= 247.5) {
            ret.appendContentsOf("S")
        }
        if (dir > 22.5  && dir <= 157.5) {
            ret.appendContentsOf("E")
        }
        if (dir > 202.5  && dir <= 337.5) {
            ret.appendContentsOf("W")
        }
        return ret
    }
    
    func setLocation(latitude: Double, longitude: Double) {
        lat = latitude
        long = longitude
    }
    
    func setNote(note: String) {
        text = note
    }
    
    func updateDistance(userLat: Double, userLong: Double) {
        dist = CallHandler().findDistance(userLat, long1: userLong, lat2: lat!, long2: long!)
        dir = CallHandler().findDirection(userLat, long1: userLong, lat2: lat!, long2: long!)
    }
    
    func setNoteType(noteType: String) {
        type = noteType
    }
}

class MapNote: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return ""
    }
}

class Contact: NSObject {
    let name: String?
    let user: PFUser?
    var requested: Bool = false
    
    init(name: String, user: PFUser) {
        self.name = name
        self.user = user
        super.init()
    }
}

class Update: NSObject {
    let title: String
    let desc: String
    let seen: Bool
    
    init(title: String, desc: String, seen: Bool) {
        self.title = title
        self.desc = desc
        self.seen = seen
        super.init()
    }
    
    override init() {
        self.title = ""
        self.desc = ""
        self.seen = true
        super.init()
    }
    
}

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController
        let dst: UIViewController = self.destinationViewController
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        if (src.isMemberOfClass(ListTableViewController)) {
            transition.subtype = kCATransitionFromRight
        }
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}

class SegueFromRight: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController
        let dst: UIViewController = self.destinationViewController
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        if (src.isMemberOfClass(ListTableViewController)) {
            transition.subtype = kCATransitionFromRight
        }
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}