//
//  register.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import SwiftyJSON


class Register: ObservableObject{
    
    @Published var userAuthData = UserAuthData()
    @Published var registerFeedback: String = ""
    @Published var registered: Bool = false
    
    /**
     BRAINCLOUD_INFO
     
     On our apps register page, we request the user to give email and password for the EMAIL and PASSWORD required for authentication.
     
     After a successful register, the onRegister function will be called.
     */
    func register(){
        if isValidEmail(userAuthData.email){
            if userAuthData.password.count >= 8{
                AppDelegate._bc.authenticateEmailPassword(userAuthData.email, password: userAuthData.password,
                                                          forceCreate: true,
                                                          completionBlock: self.onRegister,
                                                          errorCompletionBlock: self.onRegisterFailed,
                                                          cbObject: nil)
            } else {
                registerFeedback = "Password must be more than 8 characters!"
            }
        } else {
            registerFeedback = "Invalid email"
        }
    }
    
    /**
     BRAINCLOUD_INFO
     
     After our user logs in, we are going to see if they are a newUser, and if they are, we are going to update their "name" to match the name they entered on the register screen
     */
    func onRegister(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        if let jData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let json = JSON(jData)
            
            let isNewUser = json["data"]["newUser"].boolValue
            
            if(!isNewUser) {
                // If they aren't a new user, we are going to logout, and throw an error that they need to login instead
                registerFeedback = "Email is already exists, please log in instead."
            }
            
        }
        
    }
    
    func onRegisterFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        switch reasonCode {
        case 90001:
            self.registerFeedback = "The Internet connection appears to be offline."
            break
        case 40214:
            self.registered = true
            break
        default:
            self.registerFeedback = "Error. If user already exists, please login instead."
        }
        
    }
}
