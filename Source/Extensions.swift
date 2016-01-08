//
//  Extensions.swift
//  cityos-led
//
//  Created by Said Sikira on 9/20/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func mainColor() -> UIColor {
        return UIColor(
            red:0,
            green:0.64,
            blue:0.74, alpha:1
        )
    }
}

extension UIFont {
    class func mainFont() -> UIFont {
        return UIFont(name: "Arcon-Regular", size: 20)!
    }
    
    class func mainFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Arcon-Regular", size: size)!
    }
}

class Gradient {
    class func mainGradient() -> CAGradientLayer {
        let color2 = UIColor(
            red:0.15,
            green:0.77,
            blue:0.79,
            alpha:1
            ).CGColor
        
        let color1 = UIColor(
            red:0.02,
            green:0.64,
            blue:0.75,
            alpha:1
            ).CGColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            color1,
            color2
        ]
        
        return gradientLayer
    }
}

extension UIView {
    func addGradientAsBackground() {
        let gradient = Gradient.mainGradient()
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            )
            .instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

extension UINavigationController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if self.topViewController is ChartsViewController {
            return .Portrait
        }
        
        if self.topViewController is LampDetailChartsViewController {
            return .Portrait
        }
        
        return UIInterfaceOrientationMask.All
    }
}

extension CollectionType where Generator.Element == NSLayoutConstraint {
    func activateConstraints() {
        NSLayoutConstraint.activateConstraints(self as! [NSLayoutConstraint])
    }
    
    func deactivateConstraints() {
        NSLayoutConstraint.deactivateConstraints(self as! [NSLayoutConstraint])
    }
}

extension UIScrollView {
    enum UIScrollViewError : ErrorType {
        case PageDoesNotExist(page: Int)
    }
    
    var numberOfPages : Int {
        let fullWidth = self.contentSize.width
        let width = self.frame.width
        let pages = Int(fullWidth / width)
        return pages
    }
    
    var currentPage : Int {
        let page = self.contentOffset.x / self.frame.size.width
        return Int(page)
    }
    
    func goToPage(page: Int) throws {
        if page > numberOfPages - 1 {
            throw UIScrollViewError.PageDoesNotExist(page: page)
        }
        
        let x = self.frame.width * CGFloat(page)
        self.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
}