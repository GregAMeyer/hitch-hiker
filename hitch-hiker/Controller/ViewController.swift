//
//  ViewController.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/7/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        gradientView.setupGradientView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gradientView.setupGradientView()
    }
    

}

