//
//  AppDelegate.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 14..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import UIKit
import BrainCloud
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    static var _bc: BrainCloudWrapper = BrainCloudWrapper();
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //            SEGMENT_ANALYTICS_INFO
        Analytics.shared.setup()
        
        //            FACEBOOK_INFO
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //            BRAINCLOUD_INFO
        // We need to create the brainCloud Wrapper
        AppDelegate._bc = BrainCloudWrapper()
        
        // Let's enable debug logging to the console, to help with testing
        AppDelegate._bc.getBCClient().enableLogging(false)
        
        // Now let's pair this brainCloud Client with our app on the brainCloud dashboard
        
        // We need to change YOUR_SECRET and YOUR_APPID to match what is on the brainCloud dashboard.
        // See the readme for more info: https://github.com/getbraincloud/braincloud-objc/blob/master/README.md
        // TO FILL
        AppDelegate._bc.initialize("https://sharedprod.braincloudservers.com/dispatcherv2",
                                   secretKey: "", // SecretKey
                                   appId: "", // AppId
                                   version: "1.0.1",
                                   companyName: "Kirlos Yousef",
                                   appName: "RaceMe")
        
        //            FIREBASE_INFO
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        
        //            Payment_INFO
        IAPManager.shared.startObserving()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //            FACEBOOK_INFO
        let handled = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        // Add any custom logic here.
        return handled
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            }
        }
        UserDefaults.standard.set(deviceTokenString, forKey: "deviceTokenString")
        
        PushNotificationManager.shared.registerDeviceToken()
    }
}


