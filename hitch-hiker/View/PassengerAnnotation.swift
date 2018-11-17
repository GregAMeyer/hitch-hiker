//
//  PassengerAnnotation.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 11/17/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import Foundation
import MapKit

class PassengerAnnotation: NSObject, MKAnnotation {
    //mk annotaion requires that its dynamic
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
