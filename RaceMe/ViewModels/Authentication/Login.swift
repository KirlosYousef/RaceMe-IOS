//
//  Login.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth
import SwiftyJSON
import BrainCloud


class Login: ObservableObject{
    
    @Published var userLoginData = UserAuthData()
    @Published var loginFeedback: String = ""
    @Published var newUserDataFeedback: String = ""
    @Published var loading: Bool = false
    @Published var isNewUser: Bool = false
    @Published var facebookToken: String = ""
    @Published var isLoggedIn: Bool = UserDefaults.standard.isLoggedIn()
    @Published var forgotPasswordEmail: String = ""
    @Published var milestonesAndAchievements = MilestonesAndAchievements()
    @Published var leaderboards = Leaderboards()
    private var photoNumber = 0
    
    
    // MARK: Apple Login
    
    /**
     Apple Login
     
     Will try to login with Apple and in case if there is no account authenticated with it, a new one will be made and directly authenticate with it.
     */
    func loginApple(appleUserID: String, idToken: String){
        AppDelegate._bc.authenticateApple(appleUserID, identityToken: idToken, forceCreate: true, completionBlock: onAuthenticate, errorCompletionBlock: onAuthenticateFailed, cbObject: nil)
        
        Analytics.shared.screen("Apple Authenticate")
    }
    
    
    // MARK: Facebook Login
    
    /**
     Facebook Login
     
     Will try to login with facebook and in case if there is no account authenticated with it, a new one will be made and directly authenticate with it.
     */
    func loginFacebook(){
        guard let userName = AccessToken.current?.userID else { return }
        guard let facebookToken = AccessToken.current?.tokenString else { return }
        
        AppDelegate._bc.authenticateFacebook(userName, authenticationToken: facebookToken, forceCreate: true, completionBlock: onFBAuthenticate, errorCompletionBlock: onAuthenticateFailed, cbObject: nil)
        
        Analytics.shared.screen("Facebook Authenticate")
    }
    
    
    func onFBAuthenticate(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        //        print("\(serviceOperation!) Success \(jsonData!)")
        
        if let jData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let json = JSON(jData)
            let data = json["data"]
            
            if data["newUser"].boolValue{
                let profileId = data["profileId"].stringValue
                self.scheduleWeeklyFreeTokens(profileId: profileId)
            }
        }
        onLogin()
    }
    
    
    // MARK: Login
    
    /**
     BRAINCLOUD_INFO
     
     On our apps login page, we request the user to give a email and password for the EMAIL and PASSWORD required for authentication.
     
     After a successful login, the onAuthenticate function will be called.
     */
    func login(){
        if isValidEmail(userLoginData.email){
            AppDelegate._bc.authenticateEmailPassword(userLoginData.email,
                                                      password: userLoginData.password,
                                                      forceCreate: false,
                                                      completionBlock: onAuthenticate,
                                                      errorCompletionBlock: onAuthenticateFailed,
                                                      cbObject: nil)
        } else {
            loginFeedback = "Invalid email!"
        }
        Analytics.shared.screen("Email Authenticate")
    }
    
    func onAuthenticate(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        if let jData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let json = JSON(jData)
            let data = json["data"]
            
            self.userLoginData.userName = data["playerName"].stringValue
            self.userLoginData.image = data["pictureUrl"].stringValue
            
            if self.userLoginData.userName.isEmpty{
                self.isNewUser = true
                let profileId = data["profileId"].stringValue
                self.scheduleWeeklyFreeTokens(profileId: profileId)
            } else {
                onLogin() // onLoginDone
            }
        }
    }
    
    /**
     BRAINCLOUD_INFO
     
     The user has failed to login. Perhaps they entered the wrong password, or do not have an internet connection.
     
     Display an error to the user, based on the problem that occured
     */
    func onAuthenticateFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        //        print("\(serviceOperation!) Failure \(jsonError!)")
        
        switch reasonCode {
        case 40208:
            self.loginFeedback = "Account does not exist. Please register instead."
        case 40307:
            self.loginFeedback = "Password Incorrect!"
        case 90001:
            self.loginFeedback = "The Internet connection appears to be offline."
        case 40214:
            self.loginFeedback = "Please, verify your email address first then try again."
        default:
            self.loginFeedback = "\n\(serviceOperation!) Error \(reasonCode!)"
        }
        
        onLogutDone()
    }
    
    /// Preform a few functions whenever the user isLogining using auth anyway.
    func onLogin(){
        getUserData.readUserState(milestones: milestonesAndAchievements, leaderboards: leaderboards) // To get the milestones
        onLoginDone()
    }
    
    /// Preform a few usual functions whenever the user Login using auth anyway.
    func onLoginDone(){
        UserDefaults.standard.setIsLoggedIn(value: true)
        Auth.auth().signInAnonymously(completion: nil)
        self.isLoggedIn = true
        self.loading = false
        
        isNewUser = false
        
        // Analytics
        let traits = ["Email": userLoginData.email, "username": currentUserName]
        Analytics.shared.identify(currentUserID, traits: traits)
    }
    
    
    // MARK: New User
    
    func updateUserName(profileName: String){
        UpdateUserData().updateUserName(userName: profileName)
        onLogin()
    }
    
    /// Uploads the user's picture file to the server and sets it back to his profile picture.
    func newUserPic(pictureLocalPath: String){
        if pictureLocalPath == defaultProfPic{
            UpdateUserData().updateUserPicture(pictureUrl: pictureLocalPath)
            self.userLoginData.image = defaultProfPic
            onLogin() // onLoginDone
        } else {
            uploadPictureFile(localPath: pictureLocalPath)
        }
        
        Analytics.shared.screen("New Profile Picture")
    }
    
    func uploadPictureFile(localPath: String){
        
        photoNumber = Int.random(in: 0 ..< 1000)
        
        AppDelegate._bc.fileService.uploadFile("userPictures/", cloudFilename: "profilePicture\(photoNumber)", shareable: true, replaceIfExists: true, localPath: localPath, completionBlock: onuploaded, errorCompletionBlock: onuploadedFail, cbObject: "obj" as BCCallbackObject)
    }
    
    func onuploadedFail(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?){
        
        switch reasonCode {
        case 40429:
            self.newUserDataFeedback = "Image size is too big, please choose another one."
        default:
            self.newUserDataFeedback = "Error, Please choose another image or try again later."
        }
        
        onUploadedCallback()
    }
    
    func onuploaded(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        onUploadedCallback()
    }
    
    func onUploadedCallback(){
        AppDelegate._bc.getBCClient()?.registerFileUploadCallback(onUploadedPicture, failedBlock: onUploadedPictureFail)
    }
    
    func onUploadedPicture(serviceName:String?, jsonData:String?){
        AppDelegate._bc.fileService.getCDNUrl("userPictures", cloudFileName: "profilePicture\(photoNumber)", completionBlock: onReceivedUrl, errorCompletionBlock: nil, cbObject: nil)
    }
    
    func onUploadedPictureFail(serviceName:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?){
        print(jsonError as Any)
    }
    
    func onReceivedUrl(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        if let jData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let json = JSON(jData)
            
            let newProfilePicUrl = json["data"]["appServerUrl"].stringValue
            
            UpdateUserData().updateUserPicture(pictureUrl: newProfilePicUrl)
            
            self.userLoginData.image = newProfilePicUrl
            
            //            onLogin() // onLoginDone
        }
    }
    
    /// Starts the weekly free tokens awarding after the user creates a new account.
    func scheduleWeeklyFreeTokens(profileId: String){
        print("scheduleWeeklyFreeTokens for profileId: ", profileId)
        AppDelegate._bc.scriptService.run("ResetFreeTokens", jsonScriptData: "{\"profileId\":\"\(profileId)\"}", completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
    }
    
    // MARK: Password Reset
    func forgotPassword(){
        AppDelegate._bc.resetEmailPassword(forgotPasswordEmail, withCompletionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
    }
    
    
    // MARK: Logout
    
    /// Will logout from the application server, facebook and clear the stored profile ID.
    func logout(onError: Bool = false){
        if onError{
            onLogout(serviceName: "", serviceOperation: "", jsonData: "", cbObject: nil)
        } else {
            AppDelegate._bc.playerStateService.logout(onLogout, errorCompletionBlock: onFailedLogout, cbObject: nil)
        }
    }
    
    func onLogout(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        onLogutDone()
    }
    
    func onFailedLogout(serviceName:String?, serviceOperation:String?, first: Int?, second: Int?, jsonData:String?, cbObject: NSObject?){
        onLogutDone()
    }
    
    func onLogutDone(){
        AppDelegate._bc.storedProfileId = "" // Clean the stored profile ID.
        
        self.isLoggedIn = false
        self.isNewUser = false
        self.userLoginData = UserAuthData()
        getUserData.remove()
        UserDefaults.standard.removeData()
        
        if AccessToken.isCurrentAccessTokenActive{ // If connected throw facebook, logout.
            LoginManager().logOut()
        }
        do{
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        Analytics.shared.screen("Logout")
    }
}
