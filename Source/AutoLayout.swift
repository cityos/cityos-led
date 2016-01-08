//
//  AutoLayout.swift
//  demo-led
//
//  Created by Said Sikira on 12/18/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit

extension UIView {
    enum AutoLayoutError : ErrorType {
        case ViewDoesNotHaveSuperView
    }
    
    func fillSuperview() throws {
        guard let superView = self.superview else {
            throw AutoLayoutError.ViewDoesNotHaveSuperView
        }
        var views = [String: UIView]()
        views.updateValue(self, forKey: "view")
        var constraints = [NSLayoutConstraint]()
        
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views))
        
        superView.addConstraints(constraints)
        
    }
}