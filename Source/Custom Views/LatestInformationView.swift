//
//  LatestInformationView.swift
//  demo-led
//
//  Created by Said Sikira on 12/17/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit

class LatestInformationView : UIView {
    
    //MARK: Properties
    var lampName : String?
    var location : String?
    var timeString : String?
    
    //MARK: Views
    let infoLampLabel = UILabel()
    let infoLocationLabel = UILabel()
    let infoTimeLabel = UILabel()
    
    let lampLabel = UILabel()
    let locationLabel = UILabel()
    let timeLabel = UILabel()
    
    var date : NSDate! {
        didSet {
            let stamp = formatter.stringFromDate(date)
            self.timeLabel.text = stamp
        }
    }
    
    var formatter : NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "HH:mm:ss"
    
        return f
    }()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    //MARK: Auto Layout
    var views : [String: UIView] {
        return [
            "infoLamp" : infoLampLabel,
            "infoLocation" : infoLocationLabel,
            "infoTime" : infoTimeLabel,
            
            "lamp" : self.lampLabel,
            "location" : self.locationLabel,
            "time" : self.timeLabel,
            
            "indicator" : self.activityIndicator
        ]
    }
    
    var metrics : [String: AnyObject] {
        return [
            "margin" : 12
        ]
    }
    
    func prepareViews() {
        self.infoLampLabel.translatesAutoresizingMaskIntoConstraints = false
        self.infoLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.infoTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.lampLabel.translatesAutoresizingMaskIntoConstraints = false
        self.locationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        for (_,view) in self.views {
            if view is UILabel {
                (view as! UILabel).font = UIFont.mainFontWithSize(18)
                (view as! UILabel).textColor = UIColor.whiteColor()
            }
        }
        
        self.infoLampLabel.text = "Lamp name: "
        self.infoTimeLabel.text = "Timestamp: "
        self.infoLocationLabel.text = "Reading from: "
        
        self.infoLampLabel.textColor = UIColor(white: 1, alpha: 0.7)
        self.infoLocationLabel.textColor = UIColor(white: 1, alpha: 0.7)
        self.infoTimeLabel.textColor = UIColor(white: 1, alpha: 0.7)
        
        self.lampLabel.alpha = 0
        self.locationLabel.alpha = 0
        self.timeLabel.alpha = 0
        
    }
    
    func hideData() {
        UIView.animateWithDuration(0.2) {
            self.lampLabel.alpha = 0
            self.locationLabel.alpha = 0
            self.timeLabel.alpha = 0
        }
    }
    
    func showData() {
        UIView.animateWithDuration(0.2) {
            self.lampLabel.alpha = 1
            self.locationLabel.alpha = 1
            self.timeLabel.alpha = 1
        }
    }
    
    func addConstraints() {
        self.addSubview(self.infoLampLabel)
        self.addSubview(self.infoLocationLabel)
        self.addSubview(self.infoTimeLabel)
        
        self.addSubview(self.lampLabel)
        self.addSubview(self.locationLabel)
        self.addSubview(self.timeLabel)
        
        var infoConstraints = [NSLayoutConstraint]()
        
        infoConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-margin-[infoLamp]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        infoConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-margin-[infoLocation]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        infoConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-margin-[infoTime]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        infoConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-10-[infoLamp]-[infoLocation]-[infoTime]|",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        infoConstraints.activateConstraints()
        
        var valueConstraints = [NSLayoutConstraint]()
        
        valueConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[infoLamp]-[lamp]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        valueConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[infoLocation]-[location]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        valueConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[infoTime]-[time]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        valueConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-10-[lamp]-[location]-[time]|",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        valueConstraints.activateConstraints()
        
        self.addSubview(activityIndicator)
        var activityIndicatorConstraints = [NSLayoutConstraint]()
        
        activityIndicatorConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[indicator]-20-|", options: [], metrics: nil, views: self.views))
        activityIndicatorConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|[indicator]|", options: [], metrics: nil, views: self.views))
        
        activityIndicatorConstraints.activateConstraints()
    }
    
    //MARK: Init methods
    func commonInit() {
        self.prepareViews()
        self.addConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRectZero)
        commonInit()
    }
}