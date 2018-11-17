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
import Firebase

class HomeVC: UIViewController {
    
    var delegate: CenterVCDelegate?
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    
    let revealingSplashView = RevealingSplashView(
        iconImage: UIImage(named: "launchScreenIcon")!,
        iconInitialSize: CGSize(width: 80, height: 80),
        backgroundColor: UIColor.white
    )
    
    var tableView = UITableView()
    var matchingItems: [MKMapItem] = [MKMapItem]()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    @IBOutlet weak var centerMapViewBtn: UIButton!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var destinationCircle: CircleView!
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }
    @IBAction func menuButtonWasPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        centerMapOnUserLocation()
        centerMapViewBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthStatus()
        
        mapView.delegate = self
        destinationTextField.delegate = self
        
        centerMapOnUserLocation()
        
        DataService.instance.REF_DRIVERS.observe(.value, with: { (snapshot) in
            self.loadDriverAnnotatinsFromFB()
        })
        
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
    
    func loadDriverAnnotatinsFromFB() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("userIsDriver") {
                        if driver.hasChild("coordinate") {
                            if driver.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true {
                                if let driverDict = driver.value as? Dictionary<String, AnyObject> {
                                    let coordinateArray = driverDict["coordinate"] as! NSArray
                                    let driverCoordinate = CLLocationCoordinate2D(
                                        latitude: coordinateArray[0] as! CLLocationDegrees,
                                        longitude: coordinateArray[1] as! CLLocationDegrees
                                    )
                                    let annotation = DriverAnnotation(
                                        coordinate: driverCoordinate,
                                        withKey: driver.key
                                    )
                                    
                                    var driverIsVisible: Bool {
                                        return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                            if let driverAnnotation = annotation as? DriverAnnotation {
                                                if driverAnnotation.key == driver.key {
                                                    driverAnnotation.update(
                                                        annotationPosition: driverAnnotation,
                                                        withCoordinate: driverCoordinate
                                                    )
                                                    return true
                                                }
                                            }
                                            return false
                                        })
                                    }
                                    
                                    if !driverIsVisible {
                                        self.mapView.addAnnotation(annotation)
                                    }
                                }
                            }
                            else {
                                for annotation in self.mapView.annotations {
                                    if annotation.isKind(of: DriverAnnotation.self) {
                                        if let annotation = annotation as? DriverAnnotation {
                                            if annotation.key == driver.key {
                                                self.mapView.removeAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func centerMapOnUserLocation() {
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        centerMapViewBtn.fadeTo(alphaValue: 1.0, withDuration: 0.2)
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destinationTextField.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                print("error from search:", error.debugDescription)
            }
            else if response!.mapItems.count == 0 {
                print("No search results!")
            }
            else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == destinationTextField {
            tableView.frame = CGRect(x: 20,
                                     y: view.frame.height,
                                     width: view.frame.width-40,
                                     height: view.frame.height-160)
            tableView.layer.cornerRadius = 5.0
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
            
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.tag = 18 //arbitrary num to id it
            tableView.rowHeight = 60
            
            view.addSubview(tableView)
            animateTableView(shouldShow: true) //might want to stop it from doing this if you have simply re-clicked on text field after hainv a search results already up
            
            UIView.animate(withDuration: 0.2) {
                self.destinationCircle.backgroundColor = UIColor.red
                self.destinationCircle.borderColor = UIColor.init(red: 199/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == destinationTextField {
            performSearch()
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == destinationTextField {
            if destinationTextField.text == "" {
                UIView.animate(withDuration: 0.2) {
                    self.destinationCircle.backgroundColor = UIColor.lightGray
                    self.destinationCircle.borderColor = UIColor.darkGray
                }
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //added attribute clear while editing
        matchingItems = []
        tableView.reloadData()
        centerMapOnUserLocation()
        return true
    }
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = CGRect(x: 20,
                                              y: 160,
                                              width: self.view.frame.width-40,
                                              height: self.view.frame.height-160)
            }
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20,
                                              y: self.view.frame.height,
                                              width: self.view.frame.width-40,
                                              height: self.view.frame.height-160)
            }) { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title //address
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        animateTableView(shouldShow: false)
        print("selected")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if destinationTextField.text == "" {
            animateTableView(shouldShow: false)
        }
    }
}
