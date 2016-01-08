//
//  BigMapViewController.swift
//  cityos-led
//
//  Created by Said Sikira on 9/30/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import MapKit

class BigMapViewController: UIViewController {
    
    var mapView : MKMapView!
    var annotations : [MKAnnotation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lamp map"
        
        self.mapView = MKMapView()
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.delegate = self
        
        self.view.addSubview(mapView)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[map]|",
            options: [],
            metrics: nil,
            views: ["map" : mapView])
        )
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[map]|",
            options: [],
            metrics: nil,
            views: ["map" : mapView])
        )
        
        let doneButtonItem = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: "dismissViewController"
        )
        doneButtonItem.tintColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = doneButtonItem
        
        if let annotations = annotations {
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BigMapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "lampCell"
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
            annotationView.enabled = true
            annotationView.canShowCallout = true
            
//            let btn = UIButton(type: .DetailDisclosure)
//            annotationView.rightCalloutAccessoryView = btn
            return annotationView
        }
    }
}
