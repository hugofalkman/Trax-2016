//
//  GPXViewController.swift
//  Trax
//
//  Created by H Hugo Falkman on 2016-06-26.
//  Copyright © 2016 H Hugo Falkman. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Public Model
    
    var gpxURL: NSURL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url)  { gpx in
                    if gpx != nil {
                        self.addWaypoints(gpx!.waypoints)
                    }
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpxURL = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx")
    }
    
    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    // MARK: Private Implementation
    
    private func clearWaypoints() {
        mapView?.removeAnnotations(mapView.annotations)
    }
    
    private func addWaypoints(waypoints: [GPX.Waypoint]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }
    
    private func selectWaypoint(waypoint: GPX.Waypoint) {
        
    }
    
    // MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        
        view.leftCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton,
            let url = (view.annotation as? GPX.Waypoint)?.thumbnailURL,
            let imageData = NSData(contentsOfURL: url), // blocks main queue
            let image = UIImage(data: imageData) {
            thumbnailImageButton.setImage(image, forState: .Normal)
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59) // sad face
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
    }
}

