//
//  AnyDataTableViewCell.swift
//  cityos-led
//
//  Created by Said Sikira on 9/29/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit

///Defines how cell content should be rendered based on the desired state
enum CellStatus : Int {
    
    /// White background, black content
    case Neutral = 0
    
    /// White background, green content
    case Good = 1
    
    /// White bakground, transparent content
    case Warning = 2
    
    ///Special case. Transparent background, dimmed content
    case Transparent
}


/// Abstract dynamic cell that creates it's subviews based on it's set properties.
/// `AnyDataTableViewCell` should be used for subclassing, but it can be used as a
/// base table view cell, thought it is not recommended.
class AnyDataTableViewCell: UITableViewCell {
    
    //MARK: - Cell properties
    
    ///Set this property to render image inside cell
    var imageProperty : UIImage?
    
    ///Set this property to display title inside cell
    var titleProperty : String?
    
    ///Set this property to display subtitle below title
    var leftSubtitleProperty : String?
    
    ///Set this property to display subtitle below value label
    var rightSubtitleProperty : String?
    
    ///Set this property to display value on the right side of the cell
    var valueProperty : String?
    
    ///Cell status that determines how cell content is rendered. Make sure to set it before calling `renderCell()` method
    var status : CellStatus = .Neutral
    
    //MARK: - Cell views
    private var cellImageView = UIImageView()
    private var titleLabel = UILabel()
    private var leftSubtitleLabel = UILabel()
    private var rightSubtitleLabel = UILabel()
    private var valueLabel = UILabel()
    private var cellAccessoryView = UIImageView()
    
    var showAccesoryView : Bool = true
    
    //MARK: - Auto Layout
    private var views : [String : AnyObject] {
        return [
            "super"    : contentView,
            "image"    : cellImageView,
            "title"    : titleLabel,
            "leftSub"  : leftSubtitleLabel,
            "rightSub" : rightSubtitleLabel,
            "value"    : valueLabel,
            "accesory" : cellAccessoryView
        ]
    }
    
    private var metrics : [String : AnyObject] {
        return [
            "imageSize"      : 26,
            "imageMargin"    : 10,
            "fullLeftMargin" : 36,
            "margin"         : 14
        ]
    }
    
    private func setupViews() {
        //MARK: - Setup auto resizing mask
        self.cellImageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cellAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: - Setup accessory view
        self.cellAccessoryView.image = UIImage(named: "accessory-black-icon")
        self.cellAccessoryView.alpha = 0.2
        
        //MARK: - Setup title label
        self.titleLabel.font = UIFont.mainFontWithSize(16)
        self.titleLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1)
        
        //MARK: - Setup left subtitle label
        self.leftSubtitleLabel.font = UIFont.mainFontWithSize(14)
        self.leftSubtitleLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1)
        
        //MARK: - Setup value label
        self.valueLabel.font = UIFont.mainFontWithSize(18)
        self.valueLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1)
        self.valueLabel.textAlignment = .Right
        
        //MARK: - Setup right subtitle label
        self.rightSubtitleLabel.font = UIFont.mainFontWithSize(14)
        self.rightSubtitleLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1)
    }
    
    private func addAccessoryView() {
        self.contentView.addSubview(cellAccessoryView)
        
        let centerConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[super]-(<=1)-[accesory]",
            options: [.AlignAllCenterY],
            metrics: self.metrics,
            views: self.views
        )
        
        let widthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[accesory(16)]-10-|",
            options: [],
            metrics: self.metrics,
            views: self.views
        )
        
        let heightConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[accesory(16)]",
            options: [],
            metrics: nil,
            views: self.views
        )
        
        self.contentView.addConstraints(centerConstraints)
        self.contentView.addConstraints(widthConstraints)
        self.contentView.addConstraints(heightConstraint)
    }
    
    func setupContentForCellState() {
        switch self.status {
        case .Good:
            break
        case .Neutral:
            break
        case .Transparent:
            self.backgroundColor = UIColor.clearColor()
            self.titleLabel.textColor = UIColor.whiteColor()
            self.valueLabel.textColor = UIColor.whiteColor()
            self.cellImageView.alpha = 0.5
            self.valueLabel.alpha = 0.8
            self.cellAccessoryView.image = UIImage(named: "accessory-white-icon")
            self.leftSubtitleLabel.textColor = UIColor(white: 1, alpha: 0.4)
        case .Warning:
            self.leftSubtitleLabel.textColor = UIColor(red:0.87, green:0.49, blue:0.7, alpha:1)
        }
        
    }
    
    ///Call this method to setup and render views inside the cell based on the properties set
    func renderCell() {
        self.setupViews()
        
        if showAccesoryView {
            addAccessoryView()
        }
        
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsetsZero
        
        var imageStatus : Bool = false
        
        if let image = self.imageProperty {
            imageStatus = true
            self.cellImageView.image = image
            self.contentView.addSubview(cellImageView)
            
            let centerConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[super]-(<=1)-[image]",
                options: [.AlignAllCenterY],
                metrics: self.metrics,
                views: self.views
            )
            
            let leftConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-imageMargin-[image]",
                options: [],
                metrics: self.metrics,
                views: self.views
            )
            
            self.contentView.addConstraints(centerConstraints)
            self.contentView.addConstraints(leftConstraints)
        }
        
        // Check if image property is set
        if let title = self.titleProperty {
            self.titleLabel.text = title
            self.contentView.addSubview(titleLabel)
            
            // Create leading constraint for the title
            let leftConstraintString = imageStatus ?
                "H:[image]-imageMargin-[title(200)]" :
                "H:|-margin-[title(200)]"
            
            let leftConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                leftConstraintString,
                options: [],
                metrics: self.metrics,
                views: self.views
            )
            
            self.contentView.addConstraints(leftConstraints)
            
            /// Check for subtitle
            if let leftSubtitle = self.leftSubtitleProperty {
                self.contentView.addSubview(leftSubtitleLabel)
                leftSubtitleLabel.text = leftSubtitle
                
                //Create leading constraints for the left subtitle
                let leftConstraintString = imageStatus ?
                    "H:[image]-imageMargin-[leftSub(150)]" :
                    "H:|-margin-[leftSub(150)]"
                
                let leftConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    leftConstraintString,
                    options: [],
                    metrics: self.metrics,
                    views: self.views
                )
                
                self.contentView.addConstraints(leftConstraints)
                
                let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-[title]-4-[leftSub]-|",
                    options: [],
                    metrics: nil,
                    views: self.views
                )
                self.contentView.addConstraints(verticalConstraints)
                
            } else {
                let centerConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:[super]-(<=1)-[title]",
                    options: [.AlignAllCenterY],
                    metrics: self.metrics,
                    views: self.views
                )
                
                let verticalSizeConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:[title(24)]",
                    options: [],
                    metrics: nil, views: self.views
                )
                self.contentView.addConstraints(verticalSizeConstraints)
                self.contentView.addConstraints(centerConstraints)
            }
        }
        
        if let value = self.valueProperty {
            self.valueLabel.text = value
            self.contentView.addSubview(valueLabel)
            
            let rightConstraintString = showAccesoryView ? "H:[value(200)]-[accesory]" : "H:[value(200)]-20-|"
            let rightConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                rightConstraintString,
                options: [],
                metrics: self.metrics,
                views: self.views)
            
            self.contentView.addConstraints(rightConstraints)
            
            if let rightSubtitle = rightSubtitleProperty {
                self.contentView.addSubview(rightSubtitleLabel)
                rightSubtitleLabel.text = rightSubtitle
                
                let rightConstraintString = showAccesoryView ?
                    "H:[rightSub]-imageMargin-[accesory]" :
                    "H:[leftSub(100)]-imageMargin-|"
                
                let rightConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    rightConstraintString,
                    options: [],
                    metrics: self.metrics,
                    views: self.views
                )
                
                self.contentView.addConstraints(rightConstraints)
                
                let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-[value]-4-[rightSub]-|",
                    options: [],
                    metrics: nil,
                    views: self.views
                )
                self.contentView.addConstraints(verticalConstraints)
            } else {
                let centerConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:[super]-(<=1)-[value]",
                    options: [.AlignAllCenterY],
                    metrics:
                    self.metrics,
                    views: self.views
                )
                self.contentView.addConstraints(centerConstraints)
            }
        }
        
        self.setupContentForCellState()
    }
    
    //MARK: - Cell delegate methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}