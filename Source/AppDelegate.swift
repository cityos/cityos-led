//
//  AppDelegate.swift
//  CityOS-LED
//
//  Created by Said Sikira on 10/6/15.
//  Copyright © 2015 CityOS. All rights reserved.
//

import UIKit
import LightFactory

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController : UITabBarController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //MARK: - Setup global appearance proxy
        UINavigationBar.appearance().barTintColor = UIColor.mainColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont.mainFont(), NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont.mainFont(), NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red:0.52, green:0.82, blue:0.87, alpha:1)], forState: .Disabled)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.clearColor()], forState: UIControlState.Normal)
        UITabBar.appearance().backgroundColor =  UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)
        UITabBar.appearance().tintColor = UIColor.mainColor()
        UITabBar.appearance().translucent = true
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
        
        
        UITabBar.appearance().backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        //MARK: - Setup LightFactory authorization and flows
        
        LightFactoryConfiguration.setAuth(
            username: "ceco",
            masterToken: "token"
        )
        
        LightFactoryConfiguration.configureFlows(
            inDataFlow: "f562e8c4f68056d244d594ce6",
            schemaFlow: "f562e8d2f68056d244d5950d4",
            configFlow: "f562ea9f45bb709218f2b32b8",
            lampsFlow: "f564f211a5bb7093f3e71eaa7",
            zonesFlow: "f562e8cd15bb709218f2aafd1"
        )
        
        //MARK: - Setup root view controller
        let frame = UIScreen.mainScreen().bounds
        self.window = UIWindow(frame: frame)
        
        self.rootViewController = UITabBarController()
        
        let glanceViewController = UINavigationController(rootViewController: GlanceTableViewController())
        let zonesViewController = UINavigationController(rootViewController: ZonesViewController())
        let lampsViewController = UINavigationController(rootViewController: LampsViewController())
        let chartsViewController = ChartsViewController()
        
        glanceViewController.tabBarItem = UITabBarItem(
            title: "Live readings",
            image: UIImage(named: "home-icon"),
            tag: 1
        )
        
        zonesViewController.tabBarItem = UITabBarItem(
            title: "Zones",
            image: UIImage(named: "zones-icon"),
            tag: 2
        )
        
        lampsViewController.tabBarItem = UITabBarItem(
            title: "Lamps",
            image: UIImage(named: "lamp-icon"),
            tag: 3
        )
        
        chartsViewController.tabBarItem = UITabBarItem(
            title: "Charts",
            image: UIImage(named: "charts-icon"),
            tag: 4
        )
        
        // Set view controllers UITabBarController manages
        let viewControllers = [
            zonesViewController,
            lampsViewController,
            chartsViewController,
            glanceViewController
        ]
        
        rootViewController?.viewControllers = viewControllers
        
        if let window = self.window {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

//MARK: - Force touch implementation
extension AppDelegate {
    
    enum ApplicationShortcuts : String {
        case Home = "openHome"
        case Zones = "openZones"
        case Lamps = "openLamps"
        case Charts = "openCharts"
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.componentsSeparatedByString(".").last!
         (type)
        if let shortcutType = ApplicationShortcuts.init(rawValue: type) {
            switch shortcutType {
            case .Home:
                 ("home")
                self.rootViewController?.selectedIndex = 0
            case .Zones:
                self.rootViewController?.selectedIndex = 1
            case .Lamps:
                self.rootViewController?.selectedIndex = 2
            case .Charts:
                self.rootViewController?.selectedIndex = 3
            }
            quickActionHandled = true
        }
        
        return quickActionHandled
    }
    
}

