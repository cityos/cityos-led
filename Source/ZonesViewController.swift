//
//  ZonesViewController.swift
//  demo-led
//
//  Created by Said Sikira on 11/12/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory
import MapKit

class ZonesViewController: UIViewController {

    var zones = [ZoneType]()
    
    //MARK: - Views and AutoLayout
    var tableView = UITableView()
    var mapView = MKMapView()
    let refreshControl = UIRefreshControl()
    let errorLabel = UILabel()
    
    var allLamps = [LampType]()
    
    var views : [String : AnyObject] {
        return [
            "tableView" : self.tableView,
            "mapView" : self.mapView
        ]
    }
    
    func setupViews() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addConstraints() {
        var tableViewConstraints = [NSLayoutConstraint]()
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.mapView)
        
        tableViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[tableView]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        tableViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[mapView]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        tableViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[mapView(200)]-0-[tableView]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        tableViewConstraints.activateConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.addConstraints()
        
        self.title = "Zones"
        
        if self.traitCollection.forceTouchCapability == .Available {
            self.registerForPreviewingWithDelegate(self, sourceView: view)
        }
        
        self.tableView.registerClass(ZoneTableViewCell.self, forCellReuseIdentifier: "zoneCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.addSubview(self.refreshControl)
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        self.refreshControl.addTarget(self, action: "refreshZones:", forControlEvents: .ValueChanged)
        
        let factory = LightFactory.sharedInstance
        factory.retrieveAllZones {
            zones, error in
            if error != nil {
                self.addErrorMessage()
            }
            
            if let zones = zones {
                
                self.errorLabel.alpha = 0
                self.zones = zones
                self.tableView.reloadData()
            }
        }
        
        factory.didRecieveError = {
            error in
            self.addErrorMessage()
        }
        
        factory.retrieveAllLamps {
            [weak self] lamps in
            self?.errorLabel.alpha = 0
            self?.allLamps = lamps!
            self?.tableView.reloadData()
            self?.addLampsToMap()
            self?.addMapExpandButton()
        }
    }
    
    func refreshZones(sender: UIRefreshControl) {
        sender.endRefreshing()
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
        errorLabel.frame = CGRect(x: 0, y: self.view.frame.height / 2 - 80, width: self.view.frame.width, height: 80)
        self.tableView.addSubview(errorLabel)
    }
    
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
            self.allLamps.map { $0.annotation()! },
            animated: true
        )
    }
    
    func didTapExpandMapButton() {
        let viewController = BigMapViewController()
        viewController.annotations = self.allLamps.map { $0.annotation()! }
        self.presentViewController(
            UINavigationController(rootViewController: viewController),
            animated: true,
            completion: nil
        )
    }
}

extension ZonesViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.zones.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("zoneCell", forIndexPath: indexPath) as! ZoneTableViewCell
        cell.titleLabel.text = self.zones[indexPath.row].name
        cell.lampID = self.zones[indexPath.row].lampIDs[1]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let details = LampsViewController()
        details.title = self.zones[indexPath.row].name
        details.zoneID = self.zones[indexPath.row].id
        self.showViewController(details, sender: self)
    }
}

extension ZonesViewController : UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
        guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ZoneTableViewCell else { return nil }
        
        let details = LampsViewController()
        details.title = self.zones[indexPath.row].name
        details.zoneID = self.zones[indexPath.row].id
        details.preferredContentSize = CGSize(width: 0.0, height: 430)
        previewingContext.sourceRect = cell.frame
        
        return details
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.showViewController(viewControllerToCommit, sender: self)
    }
}
