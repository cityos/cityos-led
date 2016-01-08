//
//  DataReadingSelectionView.swift
//  demo-led
//
//  Created by Said Sikira on 10/11/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class DataReadingSelectionView: UIView {
    
    var tapHandler : (DataReadingSelectionView -> Void)!

    @IBOutlet weak var identifier: UILabel!
    
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    
    @IBAction func mainButtonAction(sender: AnyObject) {
        if let handler = self.tapHandler {
            handler(self)
        }
    }
    
    func changeDataTypeTo(data: LiveDataType) {
        UIView.transitionWithView(mainButton, duration: 0.4, options: [UIViewAnimationOptions.CurveEaseOut], animations: {
            self.mainButton.setTitle(data.type.dataIdentifier, forState: .Normal)
            self.identifier.text = "Total \(data.unitNotation)"
            self.iconButton.setImage(data.imageIdentifier, forState: .Normal)
            }, completion: nil)
    }

}
