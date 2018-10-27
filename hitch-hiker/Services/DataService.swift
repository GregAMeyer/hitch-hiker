//
//  DataService.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/27/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

//Singleton
//class that is instantiated and is able to be accessed globally
//from anywhere in the app, in any file
//we can acces it, write files, read files, modify it,
//just as if it was instantiated in the class that youre accessing it from

import Foundation
import Firebase

let DB_BASE: DatabaseReference! = Database.database().reference()

class DataService {
    //to make a singleton class
    //create an instance with static -
    //when it's instantiated its available for entire app lifecycle
    //don't abuse this design pattern
    //dangerous because could use a lot of memory
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_DRIVERS = DB_BASE.child("drivers")
    private var _REF_TRIPS = DB_BASE.child("trips")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE!
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_DRIVERS: DatabaseReference {
        return _REF_DRIVERS
    }
    
    var REF_TRIPS: DatabaseReference {
        return _REF_TRIPS
    }
    
    func createFirebaseDBUser(uid: String,
                              userData: Dictionary<String, Any>,
                              isDriver: Bool) {
        if isDriver {
            REF_DRIVERS.child(uid).updateChildValues(userData)
        }
        else {
            REF_USERS.child(uid).updateChildValues(userData)
        }
    }
    
    
}

