//
//  LoginVC.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/24/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate, Alertable {
    @IBOutlet weak var emailField: RoundedTextField!
    @IBOutlet weak var passwordField: RoundedTextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var authBtn: RoundedShadowButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailField.delegate = self
        passwordField.delegate = self
        view.bindToKeyboard()
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authBtnWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            authBtn.animateButton(shouldLoad: true, withMessage: nil)
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text {
                Auth.auth().signIn(
                    withEmail: email,
                    password: password,
                    completion: { (authResult, error) in //starts getting funky here
                    if error == nil {
                        if let user = authResult?.user {
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                let userData = ["provider": user.providerID] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid,
                                                                          userData: userData,
                                                                          isDriver: false)
                            }
                            else {
                                let userData = ["provider": user.providerID,
                                                "userIsDriver": true,
                                                "isPickupModeEnabled": false,
                                "driverIsOnTrip": false] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid,
                                                                          userData: userData,
                                                                          isDriver: true)
                            }
                        }
                        print("Email user authenticated successfully with Firebase")
                        self.dismiss(animated: true, completion: nil)
                    }
                    else { //error != nil
                        //errors from signIn, before createUser
                        if let errorCode = AuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .wrongPassword:
                                print("Whoops! Wrong password...")
                                self.showAlert("Whoops! Wrong password...")
                            default:
                                print("An error has occurred signing in with that email...")
                                self.showAlert("An error has occurred signing in with that email...")
                            }
                        }
                        
                        Auth.auth().createUser(
                            withEmail: email,
                            password: password,
                            completion: { (authResult, error) in
                            if error != nil {
                                //errors from createUser
                                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                                    switch errorCode {
                                    case .invalidEmail:
                                        self.showAlert("Email invalid. Please try again.")
                                        print("Email invalid. Please try again.")
                                    default:
                                        self.showAlert("An error has occurred signing in with that email...")
                                        print("An error has occurred creating that user...")
                                    }
                                }
                            }
                            else {
                                if let user = authResult?.user {
                                    if self.segmentedControl.selectedSegmentIndex == 0 {
                                        let userData = [
                                            "provider": user.providerID
                                        ] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(
                                            uid: user.uid,
                                            userData: userData,
                                            isDriver: false)
                                        print("Successfully created a new USER with Firebase")
                                    }
                                    else {
                                        let driverData = [
                                            "provider": user.providerID,
                                            "userIsDriver": true,
                                            "isPickupModeEnabled": false,
                                            "driverIsOnTrip": false
                                        ] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(
                                            uid: user.uid,
                                            userData: driverData,
                                            isDriver: true)
                                        print("Successfully created a new DRIVER with Firebase")
                                    }
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    

}
