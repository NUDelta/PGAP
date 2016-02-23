//
//  worldObject.swift
//  pgagAudio
//
//  Created by Shawn Caeiro on 2/22/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import MapKit
import UIKit

class worldObject: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
