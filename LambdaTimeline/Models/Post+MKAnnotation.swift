//
//  Post+MKAnnotation.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import  MapKit

extension Post: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        guard let geotag = geotag else { return CLLocationCoordinate2D() }
        return geotag
    }
    
    var title: String? {
        PostTitle
    }
    
    var subtitle: String? {
        author.displayName
    }
}
