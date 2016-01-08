//
//  SetupLampViewController.swift
//  demo-led
//
//  Created by Said Sikira on 10/8/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory
import Flowthings

///Used for the setuping of single lamp
class SetupLampViewController: UIViewController {
    
    var lamp : LampType!
    
    //MARK: - Views
    var tableView = UITableView()
    var headerSetupView = UIView()
    var sliderView = UISlider()
    var separatorView = UIView()
    var sliderValueLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    var optionDialog : UIAlertController!
    
    var views : [String : AnyObject] {
        return [
            "table"     : tableView,
            "header"    : headerSetupView,
            "slider"    : sliderView,
            "separator" : separatorView,
            "valueLabel" : self.sliderValueLabel
        ]
    }
    
    var metrics : [String : AnyObject] {
        return [
            "headerHeight" : 100,
            "margin" : 20
        ]
    }
    
    var turnOn = "At sunset"
    var turnOff = "At sunrise"
    var lampState : Bool = true
    
    //MARK: - Auto layout code
    func setupViews() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.headerSetupView.translatesAutoresizingMaskIntoConstraints = false
        self.sliderView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.sliderValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.headerSetupView.backgroundColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.sliderView.maximumValue = 100
        self.sliderView.minimumValue = 0
        self.sliderView.setThumbImage(UIImage(named: "slider-lamp"), forState: UIControlState.Normal)
        self.sliderView.tintColor = UIColor(red:0, green:1, blue:1, alpha:1)
        self.sliderView.minimumTrackTintColor = UIColor(red:0, green:1, blue:1, alpha:1)
        self.sliderView.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.sliderView.continuous = false
        self.separatorView.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.9, alpha:1)
        
        self.sliderValueLabel.textColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1)
        self.sliderValueLabel.font = UIFont.mainFontWithSize(14)
        self.sliderValueLabel.textAlignment = .Center
    }
    
    func addConstraints() {
        self.view.addSubview(headerSetupView)
        self.view.addSubview(tableView)
        
        self.headerSetupView.addSubview(sliderView)
        self.headerSetupView.addSubview(separatorView)
        self.headerSetupView.addSubview(sliderValueLabel)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[header]|",
            options: [],
            metrics: nil,
            views: self.views
            ))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[table]|",
            options: [],
            metrics: nil,
            views: self.views
            ))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[header(headerHeight)]-0-[table]|",
            options: [],
            metrics: self.metrics,
            views: self.views
            ))
        
        let centerConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[header]-(<=1)-[slider]",
            options: [.AlignAllCenterY],
            metrics: self.metrics,
            views: self.views
        )
        
        self.headerSetupView.addConstraints(centerConstraints)
        self.headerSetupView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-margin-[slider]-margin-|",
            options: [],
            metrics: self.metrics,
            views: self.views
            ))
        
        self.headerSetupView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-margin-[valueLabel]-margin-|",
            options: [],
            metrics: self.metrics,
            views: self.views
            ))
        
        self.headerSetupView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[slider]-[valueLabel]-|",
            options: [],
            metrics: self.metrics,
            views: self.views
            ))
        
        self.headerSetupView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[separator]|",
            options: [],
            metrics: self.metrics,
            views: self.views
            ))
        
        self.headerSetupView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[separator(1)]|",
            options: [],
            metrics: self.metrics,
            views: self.views
            ))
        
    }
    
    func sliderValueChanged(sender: UISlider) {
        self.sliderValueLabel.text = String(format: "%.0f", sender.value)
        self.lamp.lightLevel = Int(sender.value)
        LightFactory.sharedInstance.updateLamp(lamp) {
            error in
             (error)
        }
    }
    
    //MARK: - View delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.addConstraints()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerClass(AnyDataTableViewCell.self, forCellReuseIdentifier: "setupCell")
        self.tableView.rowHeight = 50
        
        self.lamp.location?.getAddress {
            placemark,error in
            if error == nil {
                self.lamp.location!.street = placemark?.addressDictionary!["Street"] as? String
                self.lamp.location!.city = placemark?.addressDictionary!["City"] as? String
                self.tableView.reloadData()
            }
        }
        
        optionDialog = UIAlertController(title: nil, message: "Chose time interval", preferredStyle: .ActionSheet)
        optionDialog.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            })
        
        optionDialog.addAction(UIAlertAction(title: "At sunrise", style: .Default) {
            action in
            //            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            })
        
        optionDialog.addAction(UIAlertAction(title: "At sunset", style: .Default) {
            action in
            //            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.sliderView.value = Float(self.lamp.lightLevel)
    }
    
    override func viewWillAppear(animated: Bool) {
        //        self.sliderView.value = Float(lamp.ledLightLevel)
        self.sliderValueLabel.text = String(format: "%.0f", sliderView.value)
        
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(index, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Table View Source Delegate
extension SetupLampViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("setupCell", forIndexPath: indexPath) as! AnyDataTableViewCell
        cell.selectionStyle = .None
        switch indexPath.row {
        case 0:
            cell.showAccesoryView = false
            cell.titleProperty = "Turn off"
            cell.imageProperty = UIImage(named: "turn-down-icon")
            cell.valueProperty = self.turnOff
        case 1:
            cell.showAccesoryView = false
            cell.titleProperty = "Turn on"
            cell.imageProperty = UIImage(named: "turn-on-icon")
            cell.valueProperty = self.turnOn
        case 2:
            cell.showAccesoryView = false
            cell.titleProperty = "Name"
            cell.valueProperty = self.lamp.name
        default:
            cell.titleProperty = "Location"
            cell.valueProperty = self.lamp.location!.street
        }
        cell.renderCell()
        return cell
    }
}

extension SetupLampViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            break
            //            self.lampState = true
            //            self.optionDialog.message = "When to turn off lamp?"
            //            self.presentViewController(optionDialog, animated: true) {
            //                self.tableView.reloadData()
            //            }
        case 1:
            break
            //            self.lampState = false
            //            self.optionDialog.message = "When should lamp be turned on?"
            //            self.presentViewController(optionDialog, animated: true) {
            //                self.tableView.reloadData()
            //            }
        case 2:
            // name
            break
        default:
            let viewController = BigMapViewController()
            viewController.annotations = [self.lamp.annotation()!]
            self.presentViewController(
                UINavigationController(rootViewController: viewController),
                animated: true,
                completion: nil
            )
        }
    }
}
