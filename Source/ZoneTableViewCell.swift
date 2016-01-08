//
//  ZoneTableViewCell.swift
//  demo-led
//
//  Created by Said Sikira on 11/12/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class ZoneTableViewCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var readingsContainerView = UIView()
    var firstReading = ZoneReadingView()
    var secondReading = ZoneReadingView()
    var thirdReading = ZoneReadingView()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    var activityIndicatorConstraints = [NSLayoutConstraint]()
    
    var lampID = String()
    
    var readingsData = [LiveDataType]() {
        didSet {
            self.firstReading.data = readingsData[0]
            self.secondReading.data = readingsData[1]
            self.thirdReading.data = readingsData[2]
            self.activityIndicator.stopAnimating()
            
            self.firstReading.setupViewWithData()
            self.secondReading.setupViewWithData()
            self.thirdReading.setupViewWithData()
            
            UIView.animateWithDuration(0.4) {
                self.firstReading.alpha = 1
                self.secondReading.alpha = 1
                self.thirdReading.alpha = 1
            }
        }
    }
    
    var views : [String : AnyObject] {
        return [
            "title" : self.titleLabel,
            "readings" : self.readingsContainerView,
            "first" : self.firstReading,
            "second" : self.secondReading,
            "third" : self.thirdReading,
            "indicator" : self.activityIndicator
        ]
    }
    
    var metrics : [String : AnyObject] {
        return [
            "margin" : 14,
            "readingsHeight" : 60
        ]
    }
    
    func setupViews() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.readingsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel.font = UIFont.mainFontWithSize(20)
        self.titleLabel.textColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1)
        
        self.firstReading.translatesAutoresizingMaskIntoConstraints = false
        self.secondReading.translatesAutoresizingMaskIntoConstraints = false
        self.thirdReading.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        self.firstReading.alpha = 0
        self.secondReading.alpha = 0
        self.thirdReading.alpha = 0
    }
    
    func addConstraints() {
        var titleConstraints = [NSLayoutConstraint]()
        var readingsContainerConstraints = [NSLayoutConstraint]()
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(readingsContainerView)
        
        titleConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-margin-[title]-margin-|",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        titleConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-margin-[title]-margin-[readings(readingsHeight)]|",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        readingsContainerConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[readings]|",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        titleConstraints.activateConstraints()
        readingsContainerConstraints.activateConstraints()
        
        self.readingsContainerView.addSubview(firstReading)
        self.readingsContainerView.addSubview(secondReading)
        self.readingsContainerView.addSubview(thirdReading)
        
        var readingViewsConstraints = [NSLayoutConstraint]()
        
        readingViewsConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[first]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        readingViewsConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[second]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        readingViewsConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[third]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        readingViewsConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-margin-[first(==second)][second(==third)][third]|",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
        )
        
        readingViewsConstraints.activateConstraints()
        
        self.readingsContainerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        activityIndicatorConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[indicator]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        activityIndicatorConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[indicator]|",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        activityIndicatorConstraints.activateConstraints()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.addConstraints()
        self.selectionStyle = .None
        self.contentView.backgroundColor = UIColor.clearColor()
        
        LightFactory.sharedInstance.retrieveLatestReading {
            readings in
            self.readingsData = readings.allReadings
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
