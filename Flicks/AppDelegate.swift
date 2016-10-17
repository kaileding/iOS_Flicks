//
//  AppDelegate.swift
//  Flicks
//
//  Created by DINGKaile on 10/12/16.
//  Copyright © 2016 myPersonalProjects. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // set up the first view controller
        let nowPlayingView = MovieListViewController()
        nowPlayingView.requestURL = "https://api.themoviedb.org/3/movie/now_playing?api_key="
        let nowPlayingNavContr = UINavigationController(rootViewController: nowPlayingView)
        nowPlayingNavContr.navigationBar.barTintColor = UIColor(red: 256/255, green: 185.7/255, blue: 84.4/255, alpha: 1.0)
        // nowPlayingNavContr.navigationBar.setBackgroundImage(UIImage(named: "rabbits")!, for: .default)
        
        nowPlayingNavContr.tabBarItem.title = "Now Playing"
        nowPlayingNavContr.tabBarItem.image = UIImage(named: "movie")
        
        // set up the second view controller
        let topRatedView = MovieListViewController()
        topRatedView.requestURL = "https://api.themoviedb.org/3/movie/top_rated?api_key="
        let topRatedNavContr = UINavigationController(rootViewController: topRatedView)
        topRatedNavContr.navigationBar.barTintColor = UIColor(red: 256/255, green: 185.7/255, blue: 84.4/255, alpha: 1.0)
        // topRatedNavContr.navigationBar.setBackgroundImage(UIImage(named: "rabbits")!, for: .default)
        
        topRatedNavContr.tabBarItem.title = "Top Rated"
        topRatedNavContr.tabBarItem.image = UIImage(named: "star")
        
        // set up the tab bar controller to have two tabs
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor(red: 256/255, green: 185.7/255, blue: 84.4/255, alpha: 1.0)
        tabBarController.viewControllers = [nowPlayingNavContr, topRatedNavContr]
        
        // make the tab bar controller the root view controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

