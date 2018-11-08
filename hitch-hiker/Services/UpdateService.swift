//
//  UpdateService.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 11/7/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class UpdateService {
    
    static var instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if let userSnapshot = dataSnapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        DataService.instance.REF_USERS
                        .child(user.key)
                        .updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
                    }
                }
            }
        })
    }
    
    func updateDriverLocaiton(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if let driverSnapshot = dataSnapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.key == Auth.auth().currentUser?.uid {
                        if driver.childSnapshot(forPath: "isPickpModeEnabled").value as? Bool == true {
                            DataService.instance.REF_USERS
                            .child(driver.key)
                            .updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
                        }
                    }
                }
            }
        })
    }
    
}
