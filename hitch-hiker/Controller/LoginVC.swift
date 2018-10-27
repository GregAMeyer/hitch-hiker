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
    }
    
    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
