//
//  CallHandler.swift
//  Notes
//
//  Created by Eric Saba on 1/25/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import Foundation

class CallHandler {
    let typesArray: [String] = ["anon", "personal", "scenery", "restaurant", "caution"]
    
    func postAnon(note: String, lat: Double, long: Double, type: String) {
        postAnon(note, lat: lat, long: long, type: type) { (success, note) in
            if !success {
                print("error")
            }
        }
    }
    
    func postAnon(note: String, lat: Double, long: Double, type: String, completion: (success: Bool, note: PFObject) -> Void) {
        let post = PFObject(className: "AnonPost")
        post["note"] = note
        post.relationForKey("postedBy").addObject(PFUser.currentUser()!)
        post["location"] = PFGeoPoint(latitude: lat, longitude: long)
        post["type"] = type
        post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                completion(success: true, note: post)
            }
            else {
                completion(success: false, note: post)
            }
        }
    }
    
    func postPersonal(note: String, lat: Double, long: Double, forUsers: [String]) {
        postAnon(note, lat: lat, long: long, type: "personal") { (success, note) in
            if success {
                let query = PFQuery(className: "PersonalNotes")
                query.whereKey("for_user", containedIn: forUsers)
                query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                    var usernames: [String] = []
                    usernames.appendContentsOf(forUsers)
                    if error == nil {
                        if let objects = objects {
                            var notInDB: [String] = []
                            notInDB.appendContentsOf(forUsers)
                            for obj in objects {
                                obj.relationForKey("notes").addObject(note)
                                notInDB.removeAtIndex(notInDB.indexOf(obj["for_user"] as! String)!)
                                obj.saveInBackground()
                            }
                            for username in notInDB {
                                let personalNote = PFObject(className: "PersonalNotes")
                                personalNote["for_user"] = username
                                personalNote.relationForKey("notes").addObject(note)
                                personalNote.saveInBackground()
                            }
                        }
                    }
                    else {
                        if error?.code == 101 {
                            for username in usernames {
                                let personalNote = PFObject(className: "PersonalNotes")
                                personalNote["for_user"] = username
                                personalNote.relationForKey("notes").addObject(note)
                                personalNote.saveInBackground()
                            }
                        }
                        else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                    }
                })
            }
        }
    }
    
    func postFollow(fromUser: PFUser, toUser: PFUser) {
        postFollow(fromUser, toUser: toUser) { (success) in
        }
    }
    
    func getFriendshipObjectForUser(user: PFUser) -> PFObject {
        let ret = PFObject(className: "Friendships")
        ret["for_user"] = user.username
        return ret
    }
    
    func postFollow(fromUser: PFUser, toUser: PFUser, completion: (success: Bool, friends: Bool) -> Void) {
        let query = PFQuery(className: "Friendships")
        query.whereKey("for_user", containedIn:[fromUser.username!, toUser.username!])
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error != nil || objects == nil {
                if error?.code == 101 {
                    let toU = self.getFriendshipObjectForUser(toUser)
                    toU.relationForKey("requests").addObject(fromUser)
                    
                    let frU = self.getFriendshipObjectForUser(fromUser)
                    frU.relationForKey("requested").addObject(toUser)
                    
                    toU.saveInBackground()
                    frU.saveInBackground()
                    completion(success: true, friends: false)
                }
                else {
                    //no internet connection
                    completion(success: false, friends: false)
                }
            }
            else {
                if let objects = objects {
                    var to: PFObject?
                    var from: PFObject?
                    print(objects.count)
                    if objects.count >= 2 {
                        for obj in objects {
                            if ((obj["for_user"] as! String) == fromUser.username) {
                                from = obj
                            }
                            if ((obj["for_user"] as! String) == toUser.username) {
                                to = obj
                            }
                        }
                        
                        let reqQuery = from!.relationForKey("requests").query()
                        reqQuery.whereKey("username", equalTo: toUser.username!)
                        reqQuery.getFirstObjectInBackgroundWithBlock({ (object: PFObject?, error: NSError?) in
                            if error == nil {
                                from!.relationForKey("requests").removeObject(toUser)
                                from!.relationForKey("friends").addObject(toUser)
                                to!.relationForKey("requested").removeObject(fromUser)
                                to!.relationForKey("friends").addObject(fromUser)
                                to!.saveInBackground()
                                from!.saveInBackground()
                                completion(success: true, friends: true)
                            }
                            else {
                                if error?.code == 101 {
                                    from!.relationForKey("requested").addObject(toUser)
                                    to!.relationForKey("requests").addObject(fromUser)
                                    to!.saveInBackground()
                                    from!.saveInBackground()
                                    completion(success: true, friends: false)
                                }
                                else {
                                    completion(success: false, friends: false)
                                }
                            }
                        })
                    }
                    else {
                        if ((objects[0]["for_user"] as! String) == fromUser.username) {
                            from = objects[0]
                            to = self.getFriendshipObjectForUser(toUser)
                        }
                        else {
                            to = objects[0]
                            from = self.getFriendshipObjectForUser(fromUser)
                        }
                        to!.relationForKey("requests").addObject(fromUser)
                        from!.relationForKey("requested").addObject(toUser)
                        to!.saveInBackground()
                        from!.saveInBackground()
                        completion(success: true, friends: false)
                    }
                }
            }
        }
    }
    
    func signUpUser(user: PFUser, completion: (success: Bool, errorString: String) -> Void) {
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as! String
                completion(success: false, errorString: errorString)
            } else {
                completion(success: true, errorString: "")
            }
        }
    }
    
    func getLatestUpdate(completion: (success: Bool, update: Update, updatesObj: PFObject) -> Void) {
        let query = PFQuery(className: "Updates")
        query.orderByDescending("createdAt")
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) in
            if error == nil {
                if let object = object {
                    let title = object["title"] as! String
                    let desc = object["description"] as! String
                    let relationQuery: PFQuery = object.relationForKey("seen").query()
                    if PFUser.currentUser() != nil {
                        relationQuery.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                        relationQuery.findObjectsInBackgroundWithBlock({ (usersCompleted: [PFObject]?, relationError: NSError?) in
                            if relationError == nil {
                                if let usersCompleted = usersCompleted {
                                    let update: Update?
                                    if usersCompleted.count > 0 {
                                        update = Update(title: title, desc: desc, seen: true)
                                    } else {
                                        update = Update(title: title, desc: desc, seen: false)
                                    }
                                    completion(success: true, update: update!, updatesObj: object)
                                }
                            }
                            else {
                                print("Error: \(error!) \(error!.userInfo)")
                                let update = Update(title: "None", desc: "Desc", seen: false)
                                completion(success: false, update: update, updatesObj: object)
                            }
                        })
                    }
                }
            } else {
                let update = Update(title: "None", desc: "Desc", seen: false)
                let obj = PFObject(className: "User")
                completion(success: false, update: update, updatesObj: obj)
            }
        }
    }
    
    func addSeenToUpdate(updatesObj: PFObject) {
        updatesObj.relationForKey("seen").addObject(PFUser.currentUser()!)
        updatesObj.saveInBackground()
    }
    
    func getAllNotes(lat: Double, long: Double, completion: (success: Bool, dict: Dictionary<String, [Note]>) -> Void) {
        var retDict = Dictionary<String, [Note]>()
        for s in typesArray {
            retDict.updateValue([Note](), forKey: s)
        }
        let query = PFQuery(className:"AnonPost")
        var array: [String] = []
        array.appendContentsOf(typesArray)
        array.removeAtIndex(array.indexOf("personal")!)
        query.whereKey("type", containedIn: array)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let note = Note(noteObj: object, userLat: lat, userLong: long)
                        retDict[note.type!]?.append(note)
                    }
                }
                self.getPersonalNotes(lat, long: long, completion: { (success, notes) in
                    if success {
                        retDict["personal"]?.appendContentsOf(notes)
                        completion(success: true, dict: retDict)
                    }
                    else {
                        completion(success: false, dict: retDict)
                    }
                })
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                completion(success: false, dict: retDict)
            }
        }
    }
    
    func getPersonalNotes(lat: Double, long: Double, completion: (success: Bool, notes: [Note]) -> Void) {
        let query = PFQuery(className: "PersonalNotes")
        query.whereKey("for_user", equalTo: (PFUser.currentUser()?.username)!)
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) in
            var ret: [Note] = []
            if error == nil {
                if let object = object {
                    object.relationForKey("notes").query().findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error2: NSError?) in
                        if error2 == nil {
                            if let objects = objects {
                                for object in objects {
                                    let note = Note(noteObj: object, userLat: lat, userLong: long)
                                    ret.append(note)
                                }
                            }
                            completion(success: true, notes: ret)
                        }
                        else {
                            if error2?.code == 101 {
                                completion(success: true, notes: ret)
                            } else {
                                completion(success: false, notes: ret)
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                        }
                    })
                }
            }
            else {
                if error?.code == 101 {
                    let personalNote = PFObject(className: "PersonalNotes")
                    personalNote["for_user"] = PFUser.currentUser()?.username
                    personalNote.saveInBackground()
                    completion(success: true, notes: ret)
                }
                else {
                    completion(success: false, notes: ret)
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    func getUserForNote(note: PFObject, completion: (success: Bool, username: String) -> Void) {
        note.relationForKey("postedBy").query().getFirstObjectInBackgroundWithBlock { (obj: PFObject?, error: NSError?) in
            if error == nil {
                if let obj = obj as? PFUser{
                    completion(success: true, username: obj.username!)
                }
            }
            completion(success: false, username: "")
        }
    }
    
    func getUsernamePhoneNumberDict(completion: (success: Bool, dict: Dictionary<String, PFUser>) -> Void) {
        var retDict = Dictionary<String, PFUser>()
        let query = PFQuery(className: "_User")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let user = object as! PFUser
                        if let number = user["phoneNumber"] {
                            retDict[number as! String] = user
                        }
                    }
                }
                completion(success: true, dict: retDict)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                completion(success: false, dict: retDict)
            }
        }
    }
    
    func getUserByNumber(phoneNum: String, completion: (success: Bool, username: String) -> Void) {
        var username = ""
        let query = PFQuery(className: "_User")
        query.whereKey("phoneNumber", equalTo: phoneNum)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    if objects.count > 0 {
                        username = objects[0].valueForKey("username") as! String
                    }
                }
                completion(success: true, username: username)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                completion(success: false, username: username)
            }
        }
    }
    
    func getFriends(fromUsername: String, completion: (success: Bool, friends: [PFUser]) -> Void) {
        let query = PFQuery(className: "Friendships")
        query.whereKey("for_user", equalTo: fromUsername)
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) in
            var ret: [PFUser] = []
            if error == nil {
                if let object = object {
                    object.relationForKey("friends").query().findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, secondError:NSError?) in
                        if secondError == nil {
                            if let objects = objects {
                                for obj in objects {
                                    ret.append(obj as! PFUser)
                                }
                                completion(success: true, friends: ret)
                            }
                        } else {
                            completion(success: false, friends: ret)
                        }
                    })
                }
            }
            else if error?.code == 101 {
                let friendship = PFObject(className: "Friendships")
                friendship["for_user"] = fromUsername
                friendship.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    completion(success: success, friends: ret)
                })
            }
            else {
                completion(success: false, friends: ret)
            }
        }
    }
    
    func getFriends(completion: (success: Bool, friends: [PFUser]) -> Void) {
        getFriends((PFUser.currentUser()?.username)!) { (success, friends) in
            completion(success: success, friends: friends)
        }
    }
    
    func getRequested(completion: (success: Bool, requested: [PFUser]) -> Void) {
        let query = PFQuery(className: "Friendships")
        query.whereKey("for_user", equalTo: (PFUser.currentUser()?.username)!)
        query.getFirstObjectInBackgroundWithBlock { (obj: PFObject?, err: NSError?) in
            var ret: [PFUser] = []
            if err == nil {
                if let obj = obj {
                    obj.relationForKey("requested").query().findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) in
                        if error == nil {
                            if let objects = objects {
                                for user in objects {
                                    ret.append(user as! PFUser)
                                }
                                completion(success: true, requested: ret)
                            }
                        }
                        else {
                            completion(success: false, requested: ret)
                        }
                    })
                }
            } else {
                completion(success: false, requested: ret)
            }
        }
    }
    
    func findDistance(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double {
        let r = 6371000.0
        let phi1 = lat1 / (180.0 / M_PI)
        let phi2 = lat2 / (180.0 / M_PI)
        let deltaPhi = (lat2 - lat1) / (180.0 / M_PI)
        let deltaLambda = (long2 - long1) / (180.0 / M_PI)
        let a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) + (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2))
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = r * c
        return d * 1.0936
    }
    
    func findDirection(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double {
        let phi1 = lat1 / (180.0 / M_PI)
        let phi2 = lat2 / (180.0 / M_PI)
        let deltaLambda = (long2 - long1) / (180.0 / M_PI)
        let curDir = atan2(sin(deltaLambda) * cos(phi2), (cos(phi1) * sin(phi2)) - (sin(phi1) * cos(phi2) * cos(deltaLambda)))
        return (((curDir * (180.0 / M_PI)) + 360) % 360)
    }
}