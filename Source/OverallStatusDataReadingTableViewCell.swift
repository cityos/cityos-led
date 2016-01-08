//
//  GlanceTableViewCell.swift
//  cityos-led
//
//  Created by Said Sikira on 10/2/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class GlanceTableViewCell: AnyDataTableViewCell {

    var data : LiveDataType! {
        didSet {
            assert(data != nil, "data property is set to nil")
            self.selectionStyle = .None
            self.status = .Transparent
            self.imageProperty = data.imageIdentifier
            self.titleProperty = data.type.dataIdentifier
            self.valueProperty = String(format: "%.1f", (data.currentDataPoint?.value)!) + " " + data.unitNotation
            self.renderCell()
        }
    }
}
