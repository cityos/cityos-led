//
//  DataReadingTableViewCell.swift
//  cityos-led
//
//  Created by Said Sikira on 9/30/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class DataReadingTableViewCell: AnyDataTableViewCell {
    
    var lampData : LiveDataType! {
        didSet {
            self.selectionStyle = .None
            self.showAccesoryView = false
            self.titleProperty = lampData.type.dataIdentifier
            self.imageProperty = lampData.blueImageIdentifier
            self.valueProperty = String(format: "%.2f", (self.lampData.currentDataPoint?.value)!) + " " + self.lampData.unitNotation
            self.renderCell()
        }
    }
}
