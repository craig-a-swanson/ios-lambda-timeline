//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var postController: PostController?
    var posts: [Post] = [] {
        didSet {
            let oldPosts = Set(oldValue)
            let newPosts = Set(posts)
            
            let addedPosts = Array(newPosts.subtracting(oldPosts))
            let removedPosts = Array(oldPosts.subtracting(newPosts))
            
            mapView.removeAnnotations(removedPosts)
            mapView.addAnnotations(addedPosts)
        }
    }
    
    private let locationManager = CLLocationManager()
    private let annotationReuseIdentifier = "PostAnnotations"
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = tabBarController as? TabbedViewController
        postController = tabBar?.postController
        
        locationManager.requestWhenInUseAuthorization()
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationReuseIdentifier)
        
        fetchPosts()
    }
 
    func fetchPosts() {
        let visibleRegion = mapView.visibleMapRect
        
        guard let postController = postController else { return }
        
        let fetchedPosts = postController.posts.filter { $0.geotag != nil }
        self.posts = fetchedPosts
        
    }
}
