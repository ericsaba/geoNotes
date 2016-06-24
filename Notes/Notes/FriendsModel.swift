//
//  FriendsModel.swift
//  geoNotes
//
//  Created by Eric Saba on 3/27/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import Foundation
import Contacts

class FriendsModel: NSObject {
    var usernamesDict: Dictionary<String, String> = Dictionary<String, String>()
    var contacts: [CNContact] = []
    var potentialFriends: [Contact] = []
    var currentFriends: [Contact] = []
    var curUser: PFUser = PFUser()
    var tableView: UITableView?
    
    init(tableView: UITableView, curUser: PFUser) {
        self.tableView = tableView
        self.curUser = curUser
        super.init()
    }
    
    func getData() {
        //add error alerts
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            let contactStore = AppDelegate.getAppDelegate().contactStore
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                CNContactEmailAddressesKey,
                CNContactPhoneNumbersKey]
            
            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containersMatchingPredicate(nil)
            } catch {
                print("Error fetching containers.")
            }
            
            // Iterate all containers and append their contacts to our results array
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                
                do {
                    let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                    let currentUserNum = PFUser.currentUser()!["phoneNumber"] as! String
                    for contact in containerResults {
                        for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                            let a: String = (phoneNumber.value as! CNPhoneNumber).stringValue
                            //link contacts with users
                            if a.characters.count >= 12 {
                                let phoneNum = self.getLiteralNumber(a)
                                if currentUserNum != phoneNum {
                                    self.contacts.append(contact)
                                }
                            }
                        }
                    }
                    self.tableView!.reloadData()
                    self.findUsernames()
                } catch {
                    print("Error fetching results for container.")
                }
            }
        }
    }
    
    func findUsernames() {
        CallHandler().getUsernamePhoneNumberDict { (success, dict) -> Void in
            if success == true {
                for contact in self.contacts {
                    if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                        for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                            let a: String = (phoneNumber.value as! CNPhoneNumber).stringValue
                            //link contacts with users
                            if a.characters.count >= 12 {
                                let phoneNum = self.getLiteralNumber(a)
                                if let user = dict[phoneNum] {
                                    let curCon = Contact(name: String(format: "%@ %@", arguments: [contact.givenName, contact.familyName]), user: user)
                                    self.potentialFriends.append(curCon)
                                    self.contacts.removeAtIndex(self.contacts.indexOf(contact)!)
                                }
                            }
                        }
                    }
                }
                self.tableView!.reloadData()
                self.findRequested()
            }
            else {
                print("Error finding potential friends.")
            }
        }
    }
    
    func findRequested() {
        CallHandler().getRequested { (success, requested) in
            if success {
                var reqUsernames: [String] = []
                for user in requested {
                    reqUsernames.append(user.username!)
                }
                for contact in self.potentialFriends {
                    if reqUsernames.contains(contact.user!.username!) {
                        contact.requested = true
                    }
                }
                self.tableView?.reloadData()
                self.findFriends()
            }
            else {
                print("Error finding requested.")
            }
        }
    }
    
    func findFriends() {
        CallHandler().getFriends(curUser.username!) { (success, friends) in
            if success {
                for user in friends {
                    for pot in self.potentialFriends {
                        if user.username! == pot.user?.username! {
                            self.potentialFriends.removeAtIndex(self.potentialFriends.indexOf(pot)!)
                            self.currentFriends.append(pot)
                        }
                    }
                }
            }
            else {
                print("Error finding friends.")
            }
            self.tableView!.reloadData()
        }
    }
    
    func getLiteralNumber(extended: String) -> String{
        var phoneNum = ""
        if extended[extended.startIndex..<extended.startIndex.advancedBy(3)] == "+1 " {
            phoneNum = String(format: "%@%@%@", arguments: [extended[extended.startIndex.advancedBy(4)..<extended.endIndex.advancedBy(-10)], extended[extended.startIndex.advancedBy(9)..<extended.endIndex.advancedBy(-5)], extended[extended.startIndex.advancedBy(13)..<extended.endIndex]])
        } else if extended[extended.startIndex..<extended.startIndex.advancedBy(2)] == "+1" {
            phoneNum = extended[extended.startIndex.advancedBy(2)..<extended.endIndex]
        } else if extended[extended.startIndex..<extended.startIndex.advancedBy(1)] == "(" {
            phoneNum = String(format: "%@%@%@", arguments: [extended[extended.startIndex.advancedBy(1)..<extended.endIndex.advancedBy(-10)], extended[extended.startIndex.advancedBy(6)..<extended.endIndex.advancedBy(-5)], extended[extended.startIndex.advancedBy(10)..<extended.endIndex]])
        } else {
            phoneNum = String(format: "%@%@%@", arguments: [extended[extended.startIndex..<extended.endIndex.advancedBy(-9)], extended[extended.startIndex.advancedBy(4)..<extended.endIndex.advancedBy(-5)], extended[extended.startIndex.advancedBy(8)..<extended.endIndex]])
        }
        return phoneNum
    }
}