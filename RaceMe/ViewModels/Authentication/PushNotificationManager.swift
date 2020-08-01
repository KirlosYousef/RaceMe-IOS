//
//  PushNotificationManager.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 27..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications
import BrainCloud

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    static let shared = PushNotificationManager()
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        Messaging.messaging().delegate = self
        
        UIApplication.shared.registerForRemoteNotifications()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func registerDeviceToken(){
        if let deviceTokenString = UserDefaults.standard.value(forKey: "deviceTokenString") as? String{
            let platform = PlatformObjc(value: "IOS")
            
            AppDelegate._bc.getBCClient()?.pushNotificationService.registerDeviceToken(platform, deviceToken: deviceTokenString, completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
        }
    }
    
    func sendNotification(to profileId: String, title: String, body: String, type: NotificationType){
        
        let alertContentJson = "{\"body\":\"\(body)\",\"title\":\"\(title)\",\"sound\":\"default\",\"badge\":1}"
        
        let customDataJson = "{\"type\":\"\(type.rawValue)\"}"
        
        AppDelegate._bc.getBCClient()?.pushNotificationService.sendNormalizedPushNotification(profileId, alertContentJson: alertContentJson, customDataJson: customDataJson, completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
    }
}
