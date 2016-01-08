//
//  LampsViewController.swift
//  cityos-led
//
//  Created by Said Sikira on 9/29/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import MapKit
import LightFactory

/// Use LampsViewController to present lamps data in a table view interface
class LampsViewController: UIViewController {
    
    //MARK: - Class properties
    
    let factory = LightFactory.sharedInstance
    
    /// Lamps that are displayed
    var lamps = [LampType]()
    
    /// If zone ID is set, data is fetched from the specified zone
    var zoneID : String?
    
    //MARK: - Views and Auto Layout
    var mapView = MKMapView()
    var tableView = UITableView()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    let errorLabel = UILabel()
    
    var views : [String : AnyObject] {
        return [
            "mapView"   : self.mapView,
            "tableView" : self.tableView
        ]
    }
    
    var metrics : [String : AnyObject] {
        return [
            "bottom" : self.tabBarController?.tabBar.frame.height ?? 0
        ]
    }
    
    func setupViews() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(mapView)
        self.view.addSubview(tableView)
        
        self.view.clipsToBounds = true
        self.tableView.registerClass(AnyDataTableViewCell.self, forCellReuseIdentifier: "lampCell")
        self.tableView.rowHeight = 60
    }
    
    func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[mapView]|",
                options: [],
                metrics: nil,
                views: views)
        )
        
        constraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[tableView]|",
                options: [],
                metrics: nil,
                views: views)
        )
        
        constraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[mapView(200)]-0-[tableView]-bottom-|",
                options: [],
                metrics: metrics,
                views: views)
        )
        constraints.activateConstraints()
    }
    //MARK: - Map view utility methods
    
    /// Add expand button
    func addMapExpandButton() {
        let expandMapButton = UIButton()
        expandMapButton.layer.shadowColor = UIColor.blackColor().CGColor
        expandMapButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        expandMapButton.layer.shadowOpacity = 0.2
        expandMapButton.setImage(UIImage(named: "circle-expand"), forState: UIControlState.Normal)
        expandMapButton.addTarget(
            self,
            action: "didTapExpandMapButton",
            forControlEvents: .TouchUpInside
        )
        expandMapButton.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: - Setup expand button constraints
        self.mapView.addSubview(expandMapButton)
        
        let bottomConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[expand(40)]-10-|",
            options: [],
            metrics: nil,
            views: ["expand" : expandMapButton]
        )
        
        let rightConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[expand(40)]-10-|",
            options: [],
            metrics: nil,
            views: ["expand" : expandMapButton]
        )
        
        self.mapView.addConstraints(bottomConstraints)
        self.mapView.addConstraints(rightConstraints)
    }
    
    /// Adds annotations to the map view
    func addLampsToMap() {
        self.mapView.showAnnotations(
            self.lamps.map { $0.annotation()! },
            animated: true
        )
    }
    
    func didTapExpandMapButton() {
        let viewController = BigMapViewController()
        viewController.annotations = self.lamps.map { $0.annotation()! }
        self.presentViewController(
            UINavigationController(rootViewController: viewController),
            animated: true,
            completion: nil
        )
    }
    
    //MARK: - View delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.title == nil {
            self.title = "Lamps"
        }
        self.setupViews()
        self.addConstraints()
        
        self.mapView.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0)
        self.activityIndicator.startAnimating()
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshLamps:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        if let zone = self.zoneID {
            factory.getLampsForZone(zone) {
                [weak self] lamps in
                self?.errorLabel.alpha = 0
                self?.lamps = lamps
                self?.tableView.reloadData()
                self?.addLampsToMap()
                self?.activityIndicator.stopAnimating()
                self?.addMapExpandButton()
            }
        } else {
            factory.retrieveAllLamps {
                [weak self] lamps in
                self?.errorLabel.alpha = 0
                self?.lamps = lamps!
                self?.tableView.reloadData()
                self?.addLampsToMap()
                self?.activityIndicator.stopAnimating()
                self?.addMapExpandButton()
            }
            
            try! factory.startUpdatingLamps {
                [weak self] lamps in
                self?.errorLabel.alpha = 0
                self?.lamps = LightFactory.sharedInstance.lamps
                self?.tableView.reloadData()
                self?.addLampsToMap()
                self?.activityIndicator.stopAnimating()
            }
        }
        
        factory.didRecieveError = {
            error in
            self.addErrorMessage()
        }
    }
    
    func refreshLamps(sender: UIRefreshControl) {
        sender.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selected, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addErrorMessage() {
        errorLabel.text = "An error occurred.\nSorry about that"
        errorLabel.textColor = UIColor(white: 0, alpha: 0.4)
        errorLabel.textAlignment = .Center
        errorLabel.font = UIFont.mainFontWithSize(20)
        errorLabel.numberOfLines = 2
        errorLabel.frame = CGRect(x: 0, y: self.tableView.frame.height / 2 - 80, width: self.view.frame.width, height: 80)
        self.tableView.addSubview(errorLabel)
    }
}

extension LampsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lamps.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("lampCell", forIndexPath: indexPath) as! AnyDataTableViewCell
        
        cell.imageProperty = UIImage(named: "lamp-icon")
        cell.titleProperty = self.lamps[indexPath.row].name
        cell.renderCell()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AnyDataTableViewCell
        
        let detailViewController = LampDetailViewController()
        detailViewController.lamp = self.lamps[indexPath.row]
        detailViewController.title = cell.titleProperty!
        self.showViewController(detailViewController, sender: self)
    }
}

extension LampsViewController : MKMapViewDelegate {
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