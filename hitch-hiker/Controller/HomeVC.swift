//
//  HomeVC.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/7/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView
import CoreLocation

class HomeVC: UIViewController {
    
    var delegate: CenterVCDelegate?
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    
    let revealingSplashView = RevealingSplashView(
        iconImage: UIImage(named: "launchScreenIcon")!,
        iconInitialSize: CGSize(width: 80, height: 80),
        backgroundColor: UIColor.white
    )

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }
    @IBAction func menuButtonWasPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        centerMapOnUSerLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthStatus()
        
        mapView.delegate = self
        
        centerMapOnUSerLocation()
        
        gradientView.setupGradientView()
        
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager?.startUpdatingLocation()
        }
        else {
            manager?.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnUSerLocation() {
        let coordinateRegion = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: regionRadius * 2.0,
            longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gradientView.setupGradientView()
    }
    

}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
//            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view
        }
        return nil
    }
}

