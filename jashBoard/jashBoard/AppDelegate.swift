//
//  AppDelegate.swift
//  jashBoard
//
//  Created by Harichandan Singh on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        let tabController = UITabBarController()
        
        let categorySelectionTVC = CategorySelectionTableViewController()
        
        let uploadVC = UploadViewController()
        let logInVC = LogInViewController()
        
        let galleryIcon = UITabBarItem(title: "", image: UIImage(named: "gallery_icon")?.withRenderingMode(.alwaysTemplate), tag: 0)
        let cameraIcon = UITabBarItem(title: "", image: UIImage(named: "camera_icon")?.withRenderingMode(.alwaysTemplate), tag: 1)
        let userIcon = UITabBarItem(title: "", image: UIImage(named: "user_icon")?.withRenderingMode(.alwaysTemplate), tag: 2)

        categorySelectionTVC.tabBarItem = galleryIcon
        uploadVC.tabBarItem = cameraIcon
        logInVC.tabBarItem = userIcon
        
        let rootVCForCategorySelection = UINavigationController(rootViewController: categorySelectionTVC)
        let rootVCForUploadVC = UINavigationController(rootViewController: uploadVC)
        let rootVCForLogin = UINavigationController(rootViewController: logInVC)
        
        tabController.viewControllers = [rootVCForCategorySelection, rootVCForUploadVC, rootVCForLogin]
        
        tabController.tabBar.barTintColor = JashColors.lightPrimaryColor
       // tabController.tabBar.tintColor = JashColors.accentColor
        tabController.selectedIndex = 2 // Shows login as the first view
        
        self.window = UIWindow(frame: UIScreen.main.bounds)

        self.window?.rootViewController = tabController
        self.window?.makeKeyAndVisible()

        // Logs in anonymously at start of app
        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Error attempting to long in anonymously: \(error!)")
            }
            if user != nil {
                print("Signed in anonymously!")
            }
        })

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
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
       
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,
                                                      NSFontAttributeName:UIFont.systemFont(ofSize: 20)]
        navigationBarAppearace.tintColor = JashColors.accentColor
        navigationBarAppearace.barTintColor = JashColors.darkPrimaryColor
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }


}

