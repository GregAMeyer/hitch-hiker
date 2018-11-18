//
//  Alertable.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 11/18/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

protocol Alertable {}

//a protocol that allows any view controller to handle alerts
//make it apply specifically to anything that is a UIViewController

//where self inherits from UIViewController
extension Alertable where Self: UIViewController {
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil)
        
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
}
