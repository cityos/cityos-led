//
//  DateRangeSelectionView.swift
//  cityos-led
//
//  Created by Said Sikira on 9/30/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit

enum RangeType {
    case Day
    case Week
    case Month
    case Year
}

class DateRangeSelectionView: UIView {
    
    var selectedIndex : RangeType = .Day {
        didSet {
            if oldValue != selectedIndex {
                if let handler = self.rangeChanged {
                    handler(newRange: selectedIndex)
                }
            }
        }
    }
    
    var rangeChanged : ((newRange: RangeType) -> ())?
    
    var unselectedBackgroundColor : UIColor? = UIColor(
        red:16/255,
        green:194/255,
        blue:202/255,
        alpha:0.1
    )
    
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    
    @IBAction func daySelectedAction(sender: UIButton) {
        dayButton.backgroundColor = UIColor(red:0.4, green:0.83, blue:0.85, alpha:1)
        selectedIndex = .Day
        weekButton.backgroundColor = unselectedBackgroundColor
        monthButton.backgroundColor = unselectedBackgroundColor
        yearButton.backgroundColor = unselectedBackgroundColor
    }
    
    @IBAction func weekSelectedAction(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.4, green:0.83, blue:0.85, alpha:1)
        selectedIndex = .Week
        dayButton.backgroundColor = unselectedBackgroundColor
        monthButton.backgroundColor = unselectedBackgroundColor
        yearButton.backgroundColor = unselectedBackgroundColor
    }
    
    @IBAction func monthSelectedAction(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.4, green:0.83, blue:0.85, alpha:1)
        selectedIndex = .Month
        dayButton.backgroundColor = unselectedBackgroundColor
        weekButton.backgroundColor = unselectedBackgroundColor
        yearButton.backgroundColor = unselectedBackgroundColor
    }
    
    @IBAction func yearSelectedAction(sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.4, green:0.83, blue:0.85, alpha:1)
        selectedIndex = .Year
        dayButton.backgroundColor = unselectedBackgroundColor
        weekButton.backgroundColor = unselectedBackgroundColor
        monthButton.backgroundColor = unselectedBackgroundColor
    }
}
