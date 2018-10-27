//
//  LoginVC.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/24/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    

}
