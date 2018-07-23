//
//  AppDelegate.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authorization = SPTAuth()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: []) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            aps(notification["aps"] as! [String: AnyObject])
        }
        
        authorization.redirectURL = URL(string: "groupify://spotify/callback")
        authorization.sessionUserDefaultsKey = "SpotifySession"
        
        return true
    }
    
    func application(_ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        aps(userInfo["aps"] as! [String: AnyObject])
        completionHandler(.newData)
    }
    
    private func aps(_ data: [String: AnyObject]) {
        print(data)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "queueSong"), object: data)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        Queue.instance.deviceToken = token
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if authorization.canHandle(authorization.redirectURL) {
            authorization.handleAuthCallback(withTriggeredAuthURL: url, callback: {
                (error, session) in
                if (error != nil) {
                    //TODO: HANDLE ERROR
                    print("ERROR ERROR PANTS ON FIRE... in authorization.handleAuthCallback")
                }
                let udefs = UserDefaults.standard
                let data = NSKeyedArchiver.archivedData(withRootObject: session!)
                print("data:"); print(data)
                udefs.set(data, forKey: "SpotifySession")
                udefs.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessful"), object: nil)
            })
            print("login successful: application open url")
            return true
        }
        print("false returned, application open url")
        return false
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

