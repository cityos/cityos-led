//
//  HomeTableViewController.swift
//  cityos-led
//
//  Created by Said Sikira on 9/21/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

/// GlanceTableViewController is used to present agreggated data from several lamp data readings
class GlanceTableViewController: UIViewController {
    
    var ledDataSource : LiveDataCollectionType!
    let errorLabel = UILabel()
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    let gradientBackgroundView : CAGradientLayer = Gradient.mainGradient()
    
    //MARK: - Views and AutoLayout
    let tableView = UITableView()
    let readingInfoView = LatestInformationView()
    
    var didFetchLamps : Bool = false
    var lampsSource = [LampType]()
    
    var views : [String : AnyObject] {
        return [
            "tableView" : self.tableView,
            "info" : self.readingInfoView
        ]
    }
    
    func setupViews() {
        self.gradientBackgroundView.frame = self.view.bounds
        
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.view.layer.insertSublayer(gradientBackgroundView, atIndex: 0)
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor(white: 1, alpha: 0.5)
        self.tableView.rowHeight = 64
        self.tableView.alpha = 0
        self.activityIndicator.startAnimating()
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        
        self.readingInfoView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func addConstraints() {
        var tableViewConstraints = [NSLayoutConstraint]()
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.readingInfoView)
//        self.readingInfoView.backgroundColor = UIColor.whiteColor()
        
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
                "H:|[info]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        tableViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[info]-0-[tableView]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        tableViewConstraints.activateConstraints()
        
    }
    
    //MARK: - View delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Live readings"
        self.navigationController?.hidesBarsOnSwipe = true
        self.setupViews()
        self.addConstraints()
        
        self.tableView.registerClass(GlanceTableViewCell.self, forCellReuseIdentifier: "dataReading")
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.activityIndicator.startAnimating()
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(white: 1, alpha: 0.8)
        refreshControl.addTarget(self, action: "updateReadings:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        let factory = LightFactory.sharedInstance
        
        factory.retrieveLatestReading {
            [weak self] readings in
            self?.activityIndicator.stopAnimating()
            self?.ledDataSource = readings
            self?.tableView.reloadData()
            UIView.animateWithDuration(0.4) {
                self?.tableView.alpha = 1
            }
            
            self?.updateInfo()
        }
        
        factory.didRecieveError = {
            error in
            print(error)
            
            self.addErrorMessage()
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            factory.retrieveAllLamps {
                lamps in
                self.lampsSource = lamps!
                self.didFetchLamps = true
                self.updateInfo()
            }
        })
        
        self.tableView.delegate = self
        
        if self.traitCollection.forceTouchCapability == .Available {
            self.registerForPreviewingWithDelegate(self, sourceView: view)
        }
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "update:", userInfo: nil, repeats: true)
        
    }

    func update(sender: NSTimer) {
        LightFactory.sharedInstance.retrieveLatestReading {
            [weak self] readings in
            self?.ledDataSource = readings
            self?.tableView.reloadData()
            self?.updateInfo()
        }
    }
    
    func updateInfo() {
        if didFetchLamps {
            let lamp = self.lampsSource.filter {
                $0.device.id == self.ledDataSource.lampID
            }.first
            
            if let lamp = lamp {
                self.readingInfoView.hideData()
                self.readingInfoView.lampLabel.text = lamp.device.model
                self.readingInfoView.date = self.ledDataSource.creationDate
                lamp.location?.getAddress {
                    placemark,error in
                    if let place = placemark {
                        let address = place.addressDictionary!["Street"] as? String ?? ""
                        let city = place.addressDictionary!["City"] as? String ?? ""
                        self.readingInfoView.locationLabel.text = "\(address) \(city)"
                        self.readingInfoView.showData()
                    }
                    
                    if error != nil {
                        self.readingInfoView.showData()
                    }
                }
            }
        }
    }
    
    func updateReadings(sender: UIRefreshControl) {
        sender.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func addErrorMessage() {
        errorLabel.text = "An error occurred.\nSorry about that"
        errorLabel.textColor = UIColor(white: 1, alpha: 0.4)
        errorLabel.textAlignment = .Center
        errorLabel.font = UIFont.mainFontWithSize(20)
        errorLabel.numberOfLines = 2
        errorLabel.frame = CGRect(x: 0, y: self.view.frame.height / 2 - 80, width: self.view.frame.width, height: 80)
        self.view.addSubview(errorLabel)
        self.activityIndicator.stopAnimating()
    }
}

// MARK: - Table view data source
extension GlanceTableViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let source = self.ledDataSource {
            return source.allReadings.count
        }
        return 0
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
//        gradientBackgroundView.frame = size.height > size.width ?
//            CGRect(x: 0, y: 0, width: size.width, height: size.height) :
//            CGRect(x: 0, y: 0, width: size.width, height: self.tableView.contentSize.height)
//        
//        self.view.layer.insertSublayer(gradientBackgroundView, atIndex: 0)
//        coordinator.animateAlongsideTransition({
//                context in
//            self.view.addGradientAsBackground()
//            }, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientBackgroundView.frame = self.view.bounds
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("dataReading", forIndexPath: indexPath) as! GlanceTableViewCell
        
        let data = self.ledDataSource.allReadings[indexPath.row]
        cell.data = data
        cell.renderCell()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GlanceTableViewCell
        let chartsViewController = ChartsViewController()
        chartsViewController.currentDataReading = cell.data
        chartsViewController.selectDataReadingView.changeDataTypeTo(cell.data)
        chartsViewController.isPresented = true
        self.presentViewController(chartsViewController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutIfNeeded()
        
    }
}

extension GlanceTableViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        self.readingInfoView.layoutIfNeeded()
        
        let infoHeight = self.readingInfoView.frame.height
        
        var newLocation = location
        newLocation.y-=infoHeight
        
        guard let indexPath = self.tableView.indexPathForRowAtPoint(newLocation) else { return nil }
        guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? GlanceTableViewCell else { return nil }
        
        let charts = ChartsViewController()
        charts.currentDataReading = cell.data
        charts.selectDataReadingView.changeDataTypeTo(cell.data)
        charts.isPresented = true
        charts.selectDateRangeView.alpha = 0
        charts.chartLegendView.alpha = 0
        charts.preferredContentSize = CGSize(width: 0.0, height: 360)
        cell.contentView.backgroundColor = UIColor.clearColor()
        let cellFrame = cell.frame
        let newFrame = CGRect(x: 0, y: infoHeight + cellFrame.origin.y, width: cellFrame.width, height: cellFrame.height)
        previewingContext.sourceRect = newFrame
        return charts
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let vc = viewControllerToCommit as? ChartsViewController {
//            vc.preferredContentSize = self.view.frame.size
            vc.selectDateRangeView.alpha = 1
            vc.chartLegendView.alpha = 1
            vc.view.backgroundColor = UIColor(red:0.11, green:0.77, blue:0.79, alpha:1)
            vc.chartView.layoutIfNeeded()
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}
