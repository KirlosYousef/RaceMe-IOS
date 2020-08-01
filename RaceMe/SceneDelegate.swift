//
//  SceneDelegate.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 14..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import UIKit
import SwiftUI
import FBSDKCoreKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let login = Login()
    private var observerStoped = false
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        let _ = ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.
        let matchmaking = Matchmaking()
        let register = Register()
        
        // First will check the userAppleId (used in sign in with apple) and if it's authorized it will reconnect to it if not it will check using the isLoggedIn key or logout in case of revoked.
        let userAppleId = UserDefaults.standard.getUserAppleId()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userAppleId) { (state, error) in
            
            DispatchQueue.main.async {
                switch state
                {
                case .authorized: // valid user id
                    //                    self.reconnect()
                    break
                case .revoked: // user revoked authorization
                    self.login.logout()
                    break
                case .notFound: // not found
                    if UserDefaults.standard.isLoggedIn(){
                        //                        self.reconnect()
                    }
                    break
                default:
                    break
                }
            }
        }
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            window.rootViewController = UIHostingController(rootView: RootView()
                .environmentObject(register)
                .environmentObject(login)
                .environmentObject(matchmaking)
            )
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        IAPManager.shared.stopObserving()
        self.observerStoped = true
        AppDelegate._bc.getBCClient()?.rttService.disableRTT()
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if observerStoped{
            IAPManager.shared.startObserving()
            self.observerStoped = false
        }
        self.reconnect()
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func reconnect(){
        func failedToConnect(serviceName:String?, serviceOperation:String?, first: Int, Second : Int, jsonData:String?, cbObject: NSObject?){
            print("Connection failed!")
            login.logout()
        }
        
        func onConnected(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
            getUserData.readUserState(milestones: login.milestonesAndAchievements)
            
            PushNotificationManager.shared.registerDeviceToken()
        }
        
        if !(AppDelegate._bc.getBCClient()?.isAuthenticated() ?? false) && UserDefaults.standard.isLoggedIn(){
            AppDelegate._bc.reconnect(onConnected, errorCompletionBlock: failedToConnect, cbObject: nil)
        }
    }
    
}

