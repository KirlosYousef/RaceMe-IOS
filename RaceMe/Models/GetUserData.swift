//
//  GetUserData.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 31..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation
import SwiftyJSON


///This class is responsible for getting the user data such as profile name, profile picture, etc.
class GetUserData{
    
    @Published var userStats = UserStats()
    @Published var currentUserData = UserAuthData()
    
    /**
     Reads the current user data.
     
     - Remark: Will try to get the user data and store the required ones to the userDefaults.
     */
    func readUserState(milestones: MilestonesAndAchievements? = nil, leaderboards: Leaderboards? = nil){
        AppDelegate._bc.playerStateService.readUserState(onSuccess, errorCompletionBlock: nil, cbObject: nil)
        
        if milestones != nil{
            milestones!.ReadMilestones() // To get the milestones
        }
        if leaderboards != nil{
            leaderboards!.getFriendsLeaderboards()
        }
    }
    
    
    func onSuccess(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        //        print("\(serviceOperation!) Success \(jsonData!)")
        
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            
            let json = JSON(jsonData)
            
            let data = json["data"]
            
            let currentPlayerName = data["playerName"].stringValue
            currentUserData.userName = currentPlayerName
            
            let currentPlayerPhoto = data["pictureUrl"].stringValue
            if !currentPlayerPhoto.isEmpty{
                currentUserData.image = currentPlayerPhoto
            }
            
            var currentPlayerId = data["id"].stringValue
            
            if (String(describing: currentPlayerName).contains("null")){ // If there is no name, set the default one.
                currentUserData.userName = ""
            }
            
            if String(describing: currentUserData.image).contains("facebook"){ // If there is no photo, set the default one.
                currentUserData.image = "\(currentPlayerPhoto)type=large"
            }
            
            if (String(describing: currentPlayerId).contains("null")){ // If there is no id, set the default one.
                currentPlayerId = ""
            }
            
            UserDefaults.standard.setUserName(value: currentUserData.userName)
            UserDefaults.standard.setUserPhoto(value: currentUserData.image)
            UserDefaults.standard.setUserId(value: currentPlayerId)
            
            // Statistics
            let level = data["experienceLevel"].intValue
            let matchesPlayed = data["statistics"]["matchesPlayed"].intValue
            let matchesWon = data["statistics"]["matchesWon"].intValue
            let distanceRun = data["statistics"]["distanceRun"].intValue
            
            self.userStats = UserStats(level: level, matchesPlayed: matchesPlayed, matchesWon: matchesWon, distanceRun: distanceRun, dataFetched: true)
            
            //            let blockedUsers = data["summaryFriendData"].
            
            UserDefaults.standard.setIsLoggedIn(value: true)
        }
    }
    
    func remove(){
        self.currentUserData = UserAuthData()
        self.userStats = UserStats()
    }
    
    /// Returns back the user's current balance of tokens.
    func getTokens(handler: @escaping ([String: Int]) -> Void){
        
        AppDelegate._bc.virtualCurrencyService.getCurrency(nil, completionBlock: { (serviceName, serviceOperation, jsonData, cbObject) in
            if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
                
                let json = JSON(jsonData)
                
                let data = json["data"]
                let tokensBalance = data["currencyMap"]["Tokens"]["balance"].intValue
                let freeTokensBalance = data["currencyMap"]["FreeTokens"]["balance"].intValue
                let tokens = ["tokensBalance": tokensBalance, "freeTokensBalance": freeTokensBalance]
                handler(tokens)
            }
        }, errorCompletionBlock: nil, cbObject: nil)
    }
    
    /// Returns back the user's current balance of free tokens.
    func getFreeTokens(handler: @escaping (Int) -> Void){
        
        AppDelegate._bc.virtualCurrencyService.getCurrency("FreeTokens", completionBlock: { (serviceName, serviceOperation, jsonData, cbObject) in
            if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
                
                let json = JSON(jsonData)
                
                let data = json["data"]
                let tokensBalance = data["currencyMap"]["FreeTokens"]["balance"].intValue
                
                handler(tokensBalance)
            }
        }, errorCompletionBlock: nil, cbObject: nil)
    }
}
