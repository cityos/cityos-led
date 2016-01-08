//
//  ZoneReadingView.swift
//  demo-led
//
//  Created by Said Sikira on 11/12/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class ZoneReadingView: UIView {
    
    var data : LiveDataType?
    
    var imageView = UIImageView()
    var readingLabel = UILabel()
    var differenceReadingLabel = UILabel()
    
    //MARK: - Views and Auto Layout
    var views : [String : AnyObject] {
        return [
            "image" : self.imageView,
            "reading" : self.readingLabel,
            "difference" : self.differenceReadingLabel
        ]
    }
    
    var metrics : [String : AnyObject] {
        return [
            "margin" : 20,
            "imageSize" : 30
        ]
    }
    
    func setupViews() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.readingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.differenceReadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.readingLabel.font = UIFont.mainFontWithSize(18)
        self.readingLabel.textColor = UIColor(
            red:0.74,
            green:0.74,
            blue:0.74,
            alpha:1
        )
        
        self.differenceReadingLabel.font = UIFont.mainFontWithSize(13)
        self.differenceReadingLabel.textColor = UIColor(
            red:0.58,
            green:0.78,
            blue:0.32,
            alpha:1
        )
        
    }
    
    func addConstraints() {
        
        self.addSubview(imageView)
        self.addSubview(readingLabel)
        self.addSubview(differenceReadingLabel)
        
        let imageConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[image(26)]",
            options: [],
            metrics: self.metrics,
            views: self.views
        )
        
        let readingConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-2-[reading]",
            options: [],
            metrics: self.metrics,
            views: self.views
        )
        
        let trailingConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[image(26)]-[reading]-|",
            options: [],
            metrics: self.metrics,
            views: self.views
        )
        
        var differenceConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[image]-[difference]-|",
            options: [],
            metrics: nil,
            views: self.views
        )
        
        differenceConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[reading]-2-[difference]",
                options: [],
                metrics: nil,
                views: self.views
            )
        )
        
        imageConstraints.activateConstraints()
        readingConstraints.activateConstraints()
        trailingConstraints.activateConstraints()
        differenceConstraints.activateConstraints()
    }
    
    func setupViewWithData() {
        if let data = self.data {
            self.imageView.image = data.blueImageIdentifier
            self.readingLabel.text = "\(data.currentDataPoint!.value) \(data.unitNotation)"
            self.differenceReadingLabel.text = "+ 5%"
        }
        self.setupViews()
        self.addConstraints()
    }
    
    //MARK: - Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
