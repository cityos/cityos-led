//
//  LampDetailChartsViewController.swift
//  demo-led
//
//  Created by Said Sikira on 12/29/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

class LampDetailChartsViewController: UIViewController {
    
    /*
    These outlets should be removed in the next build
    */
    //MARK: Outlets
    @IBOutlet weak var dataIdentifierButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: Properties
    var lamp : LampType!
    var collection = CityOSCollection()
    
    /// Chart views that current scroll view manages
    lazy var chartViews = [ChartView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(lamp != nil, "Lamp property should be set")
        self.pageControl.alpha = 1
        self.pageControl.numberOfPages = collection.allReadings.count
        
        self.dataIdentifierButton.titleLabel?.font = UIFont.mainFontWithSize(20)
        
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        
        
    }
    
    func addCharts() {
        let count = self.collection.allReadings.count
        scrollView.layoutIfNeeded()
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        
        scrollView.contentSize = CGSize(width: CGFloat(count) * width, height: height)
        for i in Range(start: 0, end: count) {
            let x = width * CGFloat(i)
            let chartView = ChartView()
            self.chartViews.append(chartView)
            chartView.frame = CGRect(x: x, y: 0, width: width, height: height)
            self.scrollView.addSubview(chartView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.scrollView.frame.width
        let height = self.scrollView.frame.height
        let count = self.chartViews.count
        let size = CGSize(width: width * CGFloat(count), height: height)
        self.scrollView.contentSize = size
        
        for (i,view) in self.chartViews.enumerate() {
            view.frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: height)
        }
        
        do {
            try self.scrollView.goToPage(self.pageControl.currentPage)
        } catch {
            print(error)
        }
    }
    
    func fetchInitial() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            LightFactory.sharedInstance.getDataPoint(withDataType: self.collection.energy, forLamp: self.lamp) {
                dataPoints in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.chartViews[0].dataPoints = dataPoints
                    self.chartViews[0].setupChart()
                })
            }
        })
    }
    
}

extension LampDetailChartsViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) -> () {
        let pageNumber = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width));
        pageControl.currentPage = Int(pageNumber)
        
        if self.chartViews[Int(pageNumber)].dataPoints.count == 0 {
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                LightFactory.sharedInstance.getDataPoint(withDataType: self.collection.allReadings[pageNumber], forLamp: self.lamp) {
                    dataPoints in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.chartViews[pageNumber].dataPoints = dataPoints
                        self.chartViews[pageNumber].setupChart()
                    })
                }
            })
        }
        
        UIView.transitionWithView(self.dataIdentifierButton, duration: 0.2, options: .TransitionFlipFromLeft, animations: {
            self.dataIdentifierButton.setImage(self.collection.allReadings[Int(pageNumber)].imageIdentifier, forState: .Normal)
            self.dataIdentifierButton.setTitle("\(self.collection.allReadings[pageNumber].type.dataIdentifier) total \(self.collection.allReadings[Int(pageNumber)].unitNotation)", forState: .Normal)
        }, completion: nil)
        
    }
}
