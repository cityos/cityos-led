//
//  ChartsViewController.swift
//  cityos-led
//
//  Created by Said Sikira on 9/21/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory
import Charts

class ChartsViewController: UIViewController {
    
    //MARK: - Class properties
    var currentDataReading : LiveDataType! {
        didSet {
            factory.getDataPoint(forDataType: currentDataReading) {
                dataPoints in
                self.dataPoints = dataPoints
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    var showTopChoiceView : Bool = true
    var isPresented : Bool = false
    
    var dataPoints = [DataPoint]() {
        didSet {
            
            chartView.dataPoints = dataPoints
            chartView.setupChart()
            
            let first = dataPoints.first?.timestamp ?? NSDate()
            let last = dataPoints.last?.timestamp ?? NSDate()
            
            self.chartLegendView.leftLabel.text = formatter.stringFromDate(first)
            self.chartLegendView.rightLabel.text = formatter.stringFromDate(last)
        }
    }
    
    var formatter : NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "d.yy 'at' h a"
        
        return f
    }()
    
    //MARK: - Views
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    var chartContainerView = UIView()
    let closeButton = UIButton()
    
    var chartView : ChartView!
    
    let selectDateRangeView = UIView.loadFromNibNamed("DateRangeSelectionView") as! DateRangeSelectionView
    let selectDataReadingView = UIView.loadFromNibNamed("DataReadingSelectionView") as! DataReadingSelectionView
    let chartLegendView = UIView.loadFromNibNamed("ChartDateLegendView") as! ChartLegendView
    
    let infoLabel = UILabel()
    let gradientBackgroundView = Gradient.mainGradient()
    let errorLabel = UILabel()
    let tryButton = UIButton()
    
    let factory = LightFactory.sharedInstance
    
    //MARK: - Auto Layout
    var views : [String:AnyObject] {
        return [
            "activity" : self.activityIndicator,
            "chart" : self.chartContainerView,
            "option" : self.selectDateRangeView,
            "switch" : self.selectDataReadingView,
            "legend" : self.chartLegendView
        ]
    }
    
    var metrics : [String:AnyObject] {
        return [
            "top" : 22,
            "bottom" : isPresented ? 0 : 48,
        ]
    }
    
    func setupViews() {
        self.chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.selectDateRangeView.translatesAutoresizingMaskIntoConstraints = false
        self.selectDataReadingView.translatesAutoresizingMaskIntoConstraints = false
        self.chartLegendView.translatesAutoresizingMaskIntoConstraints = false
        self.chartView.translatesAutoresizingMaskIntoConstraints = false
        
        self.selectDateRangeView.backgroundColor = UIColor.clearColor()
        self.selectDateRangeView.translatesAutoresizingMaskIntoConstraints = false
        self.selectDateRangeView.daySelectedAction(selectDateRangeView.dayButton)
        
        self.chartLegendView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(selectDateRangeView)
        self.view.addSubview(chartContainerView)
        self.view.addSubview(chartLegendView)
        
        self.chartContainerView.addSubview(chartView)
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[option]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[chart]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[legend]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        if showTopChoiceView {
            self.view.addSubview(selectDataReadingView)
            self.view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[switch]|",
                    options: [],
                    metrics: nil,
                    views: self.views
                )
            )
            
            self.view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-top-[switch(60)]-[chart]-0-[legend(20)]-4-[option(60)]-bottom-|",
                    options: [],
                    metrics: self.metrics,
                    views: self.views
                )
            )
            
        } else {
            self.view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-top-[chart]-0-[legend(20)]-4-[option(60)]-bottom-|",
                    options: [],
                    metrics: self.metrics,
                    views: self.views
                )
            )
        }
        
        selectDateRangeView.rangeChanged =  {
            range in
            
        }
        
        try! self.chartView.fillSuperview()
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Charts"
        self.chartView = ChartView()
        self.chartView.chartView.noDataText = ""
        self.setupViews()
        
        if self.currentDataReading == nil {
            self.currentDataReading = CityOSCollection().allReadings[0]
        }
        
        gradientBackgroundView.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientBackgroundView, atIndex: 0)
        
        self.activityIndicator.startAnimating()
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        try! self.activityIndicator.fillSuperview()
        
        selectDataReadingView.tapHandler = {
            [weak self] sender in
            self?.displayActionSheet {
                data in
                if data != nil {
                    self?.selectDataReadingView.changeDataTypeTo(data!)
                    self?.currentDataReading = data!
                }
            }
        }
        
        if isPresented {
            self.addCloseButton()
        }
        
        factory.didRecieveError = {
            error in
            print(error)
            self.activityIndicator.stopAnimating()
            self.addErrorMessage()
        }
    }
    
    func addCloseButton() {
        closeButton.setImage(UIImage(named: "close-icon"), forState: .Normal)
        closeButton.alpha = 0.7
        closeButton.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(closeButton)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[close(25)]-20-|", options: [], metrics: nil, views: ["close" : closeButton]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-34-[close(25)]", options: [], metrics: self.metrics, views: ["close" : closeButton]))
    }
    
    func displayActionSheet(completion:(LiveDataType?) -> ()) {
        let dialog = UIAlertController(title: "Select data reading", message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
            completion(nil)
        }
        
        let dataCollection = CityOSCollection()
        
        for reading in dataCollection.allReadings {
            let readingAction = UIAlertAction(title: reading.type.dataIdentifier, style: .Default) {
                action in
                completion(reading)
            }
            
            dialog.addAction(readingAction)
        }
        dialog.addAction(cancelAction)
        self.presentViewController(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientBackgroundView.frame = self.view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        tryButton.tag = 133
        
        for s in self.view.subviews {
            if s.tag == 133 {
                return
            }
        }
        tryButton.titleLabel?.font = UIFont.mainFontWithSize(24)
        tryButton.setTitle("Try again", forState: .Normal)
        tryButton.setTitleColor(UIColor(white: 1, alpha: 0.7), forState: .Normal)
        tryButton.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: 50)
        tryButton.addTarget(self, action: "tryAgain", forControlEvents: .TouchUpInside)
        self.view.addSubview(tryButton)
    }
    
    func tryAgain() {
        self.activityIndicator.startAnimating()
        let f = LightFactory.sharedInstance
        self.tryButton.alpha = 0
        self.errorLabel.alpha = 0
        
        f.getDataPoint(forDataType: self.currentDataReading) {
            dataPoints in
            self.tryButton.removeFromSuperview()
            self.errorLabel.removeFromSuperview()
            self.dataPoints = dataPoints
            self.activityIndicator.stopAnimating()
        }
        
        f.didRecieveError = {
            error in
            self.activityIndicator.stopAnimating()
            UIView.animateWithDuration(0.4) {
                self.tryButton.alpha = 1
                self.errorLabel.alpha = 1
            }
        }
    }
}
