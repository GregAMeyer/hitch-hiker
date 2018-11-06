//
//  LeftSidePanelVC.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/15/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit
import Firebase

class LeftSidePanelVC: UIViewController {
    
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userAccountTypeLbl: UILabel!
    @IBOutlet weak var userImageView: RoundImageView!
    @IBOutlet weak var loginOutBtn: UIButton!
    @IBOutlet weak var pickupModeLbl: UILabel!
    @IBOutlet weak var pickupModeSwitch: UISwitch!
    
    let currentUserId = Auth.auth().currentUser?.uid
    let appDelegate = AppDelegate.getAppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickupModeSwitch.isOn = false
        pickupModeSwitch.isHidden = true
        pickupModeLbl.isHidden = true
        
        observePassengersAndDrivers()
        
        if Auth.auth().currentUser == nil {
            userEmailLbl.text = ""
            userAccountTypeLbl.text = ""
            userImageView.isHidden = true
            loginOutBtn.setTitle("SIGN UP / LOGIN", for: .normal)
        }
        else {
            userEmailLbl.text = Auth.auth().currentUser?.email
            userImageView.isHidden = false
            loginOutBtn.setTitle("LOGOUT", for: .normal)
        }
    }
    
    func observePassengersAndDrivers() {
        //watch firebase db
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            if let snapshot = DataSnapshot.children.allObjects as? [DataSnapshot] {
                for obj in snapshot {
                    if obj.key == Auth.auth().currentUser?.uid {
                        self.userAccountTypeLbl.text = "PASSENGER"
                    }
                }
            }
        })
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            if let snapshot = DataSnapshot.children.allObjects as? [DataSnapshot] {
                for obj in snapshot {
                    if obj.key == Auth.auth().currentUser?.uid {
                        self.userAccountTypeLbl.text = "DRIVER"
                        let switchStatus = obj.childSnapshot(forPath: "isPickupModeEnabled").value as! Bool
                        self.pickupModeSwitch.isOn = switchStatus
                        self.pickupModeLbl.text = "PICKUP MODE " + (switchStatus ? "ENABLED" : "DISABLED")
                        self.pickupModeLbl.isHidden = false
                        self.pickupModeSwitch.isHidden = false
                    }
                }
            }
        })
    }
    
    @IBAction func switchWasToggled(_ sender: Any) {
        if pickupModeSwitch.isOn {
            pickupModeLbl.text = "PICKUP MODE ENABLED"
            appDelegate.MenuContainerVC.toggleLeftPanel()
            DataService.instance
                .REF_DRIVERS.child(currentUserId!)
                .updateChildValues(["isPickupModeEnabled": true])
        }
        else {
            pickupModeLbl.text = "PICKUP MODE DISABLED"
            DataService.instance
                .REF_DRIVERS.child(currentUserId!)
                .updateChildValues(["isPickupModeEnabled": false])
        }
    }
    
    @IBAction func signUpLoginButtonWasPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            present(loginVC!, animated: true, completion: nil)
        }
        else {
            do {
                try Auth.auth().signOut()
                userEmailLbl.text = ""
                userAccountTypeLbl.text = ""
                userImageView.isHidden = true
                loginOutBtn.setTitle("SIGN UP / LOGIN", for: .normal)
                pickupModeSwitch.isOn = false
                pickupModeSwitch.isHidden = true
                pickupModeLbl.isHidden = true
            }
            catch (let error) {
                print(error)
            }
        }
    }
    

}
