//
//  AppDelegate.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import CoreData
import SlideMenuControllerSwift
import MediaPlayer
import IQKeyboardManager
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.configure(withApplicationID: GlobalClass.UD_AdAppid)
        
        IQKeyboardManager.shared().isEnabled = true
        
        Util.copyFile(fileName: "MyMusic.db")
        
        let isDeleted = Modeldata.getInstance().deleteQueueData()
        print(isDeleted)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) == nil {
            UserDefaults.standard.set(0, forKey: GlobalClass.UD_isNowPlayingTheme)
        }
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            UserDefaults.standard.set("#F23A2FFF", forKey: GlobalClass.UD_PrimaryColor)
        }
        if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) == nil {
            UserDefaults.standard.set("#000000FF", forKey: GlobalClass.UD_AccentColor)
        }
        UserDefaults.standard.set("", forKey: GlobalClass.UD_CurrentSong)
        UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPlayingQueue)
        GlobalClass.setCustomObjToUserDefaults(CustomeObj: [MPMediaItem]() as AnyObject, key: GlobalClass.UD_queueItems)
        //UserDefaults.standard.set([MPMediaItem](), forKey: GlobalClass.UD_queueItems)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_GetStart) == nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "GetStartVC") as! GetStartVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = nav
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let leftViewController = storyboard.instantiateViewController(withIdentifier: "SidemenuVC") as! SidemenuVC
            
            let nvc : UINavigationController = UINavigationController(rootViewController: mainViewController)
            nvc.isNavigationBarHidden = true
            
            let slidemenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
            slidemenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.75)
            self.window?.rootViewController = slidemenuController
        }
        
        self.getMusicPermission()
        
        return true
    }
    
    func getMusicPermission() {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Authorized")
            UserDefaults.standard.set(1, forKey: GlobalClass.UD_isPermissionGiven)
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        print("Authorized")
                        UserDefaults.standard.set(1, forKey: GlobalClass.UD_isPermissionGiven)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        print("Denied")
                        UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPermissionGiven)
                    }
                }
            }
        case .denied:
            print("Denied")
            UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPermissionGiven)
        case .restricted:
            print("Denied")
        }
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
        // Saves changes in the application's managed object context before the application terminates.
        GlobalClass.songTimer.invalidate()
        GlobalClass.homeTimer.invalidate()
        GlobalClass.globalPlayer.stop()
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "My_Music")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

