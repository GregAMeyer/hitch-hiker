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

class HomeVC: UIViewController, Alertable {
    
    var delegate: CenterVCDelegate?
//    var currentUserId = Auth.auth().currentUser?.uid
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    
    let revealingSplashView = RevealingSplashView(
        iconImage: UIImage(named: "launchScreenIcon")!,
        iconInitialSize: CGSize(width: 80, height: 80),
        backgroundColor: UIColor.white
    )
    
    var tableView = UITableView()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var selectedItemPlacemark: MKPlacemark? = nil
    var route: MKRoute!

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
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == (Auth.auth().currentUser?.uid)! {
                        if user.hasChild("tripCoordinate") {
                            self.zoom(toFitAnnotationsFromMapView: self.mapView)
                            self.centerMapViewBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        }
                        else {
                            self.centerMapOnUserLocation()
                            self.centerMapViewBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        }
                    }
                }
            }
        })
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
        else if let annotation = annotation as? PassengerAnnotation {
            let identifier = "passenger"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "currentLocationAnnotation")
            return view
        }
        else if let annotation = annotation as? MKPointAnnotation {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "destinationAnnotation")
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        centerMapViewBtn.fadeTo(alphaValue: 1.0, withDuration: 0.2)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //route has already been defined in searchMapkitForResultsWith...
        let lineRenderer = MKPolylineRenderer(overlay: self.route.polyline)
        lineRenderer.strokeColor = UIColor(red: 216/255, green: 71/255, blue: 30/255, alpha: 0.75)
        lineRenderer.lineWidth = 3
        
        zoom(toFitAnnotationsFromMapView: self.mapView)
        
        return lineRenderer
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destinationTextField.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
//                self.showAlert((error?.localizedDescription)!)
                self.showAlert("An error occurred, please try again.")
                print("error from search:", error.debugDescription)
            }
            else if response!.mapItems.count == 0 {
                self.showAlert("No search results! Please search again for a different location.")
                print("No search results!")
            }
            else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
                    self.shouldPresentLoadingView(false)
                }
            }
        }
    }
    
    func dropPinFor(placemark: MKPlacemark) {
        selectedItemPlacemark = placemark
        
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func searchMapkitForResultsWithPolyline(forMapItem mapItem: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapItem
        request.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let response = response else {
                self.showAlert(error.debugDescription)
                print(error.debugDescription)
                return
            }
            self.route = response.routes[0]
            
            //self.mapView.add(self.route!.polyline)
            self.mapView.addOverlay(self.route.polyline)
            
            self.shouldPresentLoadingView(false)
        }
    }
    
    func zoom(toFitAnnotationsFromMapView mapView: MKMapView) {
        if mapView.annotations.count == 0 {
            return
        }
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self) {
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude,
                                               annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude,
                                              annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude,
                                                   annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude,
                                                  annotation.coordinate.latitude)
        }
        
        var region = MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(
                topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5,
                topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5),
            span: MKCoordinateSpan(latitudeDelta:
                fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0,
                                   longitudeDelta:
                fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0)
        )
        
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
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
            shouldPresentLoadingView(true)
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
        
        DataService.instance.REF_USERS.child((Auth.auth().currentUser?.uid)!)
                                        .child("tripCoordinate").removeValue()
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
            else if annotation.isKind(of: PassengerAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        
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
        
        self.shouldPresentLoadingView(true)
        
        let passengerCoordinate = manager?.location?.coordinate
//        let pasengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!, key: currentUserId!)
        let pasengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!,
                                                     key: (Auth.auth().currentUser?.uid)!)
        
        mapView.addAnnotation(pasengerAnnotation)
        
        destinationTextField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        //temporarily store the selected destination locations coordinate under the user in firebase
        let selectedMapItem = matchingItems[indexPath.row]
        DataService.instance.REF_USERS.child((Auth.auth().currentUser?.uid)!)
            .updateChildValues([
                "tripCoordinate": [
                    selectedMapItem.placemark.coordinate.latitude,
                    selectedMapItem.placemark.coordinate.longitude
                ]
            ])
        
        dropPinFor(placemark: selectedMapItem.placemark)
        
        searchMapkitForResultsWithPolyline(forMapItem: selectedMapItem)
        
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
