//
//  DataTypeImage.swift
//  demo-led
//
//  Created by Said Sikira on 11/12/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import LightFactory

extension LiveDataType {
    var imageIdentifier : UIImage? {
        if self.type == .ParticleMeter10 {
            return UIImage(named: "data-pm 2.5 particles-white")
        }
        return UIImage(named: "data-\(self.type.dataIdentifier.lowercaseString)-white")
    }
    
    var blueImageIdentifier : UIImage? {
        if self.type == .ParticleMeter10 {
            return UIImage(named: "data-pm 2.5 particles-blue")
        }
        return UIImage(named: "data-\(self.type.dataIdentifier.lowercaseString)-blue")
    }
}