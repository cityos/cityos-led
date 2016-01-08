//
//  LampDetailViewController.swift
//  cityos-led
//
//  Created by Said Sikira on 9/30/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class LampDetailViewController: UIViewController {
    
    var lamp : LampType?
    var lampData : LiveDataCollectionType?
    
    //MARK: - Views
    let headerChartContainerView = UIView()
    var tableView = UITableView()
    var infoLabel = UILabel()
    lazy var chartView = ChartView()
    let gradient = Gradient.mainGradient()
    
    var views : [String : AnyObject] {
        return [
            "header" : self.headerChartContainerView,
            "tableView" : self.tableView,
            "chart" : self.chartView
        ]
    }
    
    var metrics : [String : AnyObject] {
        return [
            "bottom" : self.tabBarController?.tabBar.frame.height ?? 0
        ]
    }
    
    //MARK: - Auto Layout
    func setupViews() {
        self.headerChartContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.chartView.translatesAutoresizingMaskIntoConstraints = false
        
        self.headerChartContainerView.backgroundColor = UIColor.whiteColor()
        
        self.tableView.rowHeight = 60
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func addConstraints() {
        self.view.addSubview(headerChartContainerView)
        self.view.addSubview(tableView)
        
        self.headerChartContainerView.addSubview(self.chartView)
        
        var headerContainerConstraints = [NSLayoutConstraint]()
        var tableViewConstraints = [NSLayoutConstraint]()
        
        headerContainerConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[header]|",
                options: [],
                metrics: nil,
                views: self.views)
        )
        
        tableViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[tableView]|",
                options: [],
                metrics: nil,
                views: self.views)
        )
        
        let heightConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[header(260)]-0-[tableView]-bottom-|",
            options: [],
            metrics: self.metrics,
            views: self.views
        )
        
        self.view.addConstraints(headerContainerConstraints)
        self.view.addConstraints(tableViewConstraints)
        self.view.addConstraints(heightConstraints)
        
        let chartsController = UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewControllerWithIdentifier("LampDetailChartsController") as! LampDetailChartsViewController
        chartsController.lamp = self.lamp
        let cview = chartsController.view
        cview.backgroundColor = UIColor.clearColor()
        cview.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChildViewController(chartsController)
        self.headerChartContainerView.addSubview(cview)
        try! cview.fillSuperview()
        chartsController.addCharts()
        chartsController.fetchInitial()
    }
    
    //MARK: - View delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(lamp != nil, "Lamp property is not set")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alpha = 0
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        self.tableView.registerClass(DataReadingTableViewCell.self, forCellReuseIdentifier: "dataReadingCell")
        
        self.setupViews()
        self.addConstraints()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.gradient.frame = self.headerChartContainerView.bounds
            self.headerChartContainerView.layer.insertSublayer(self.gradient, atIndex: 0)
        })
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let setupLampItem = UIBarButtonItem(image: UIImage(named: "setup-icon"), style: .Plain, target: self, action: "setupLamp")
        self.navigationItem.rightBarButtonItem = setupLampItem

        LightFactory.sharedInstance.retrieveLatestReadingForLamp(self.lamp!.device.id) {
            [weak self] reading in
            self?.lampData = reading
            self?.tableView.reloadData()
            UIView.animateWithDuration(0.4) {
                self?.tableView.alpha = 1
            }
        }
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            LightFactory.sharedInstance.getDataPoint(forDataType: CityOSCollection().allReadings[0]) {
                dataPoints in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.chartView.dataPoints = dataPoints
                    self.chartView.setupChart()
                })
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLamp() {
        let setupLampViewController = SetupLampViewController()
        setupLampViewController.lamp = self.lamp
        setupLampViewController.title = "Manage \(self.lamp!.name!)"
        self.showViewController(setupLampViewController, sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradient.frame = self.headerChartContainerView.bounds
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
       
    }
}

extension LampDetailViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lampData == nil ? 0 : self.lampData!.allReadings.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("dataReadingCell", forIndexPath: indexPath) as! DataReadingTableViewCell
        
        cell.lampData = self.lampData!.allReadings[indexPath.row]
        cell.renderCell()
        
        return cell
    }
}
