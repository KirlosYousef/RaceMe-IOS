//
//  Friends.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 03..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation
import BrainCloud
import SwiftyJSON

/// This class is responsible for the user's friends, searching for users and adding a new friend.
class Friends: ObservableObject {
    
    @Published var userName : String = ""
    
    @Published var hasResult : Bool = true
    @Published var resultUsers = [ResultUser]()
    
    @Published var friends = [Friend]()
    @Published var loadingFriends : Bool = true
    @Published var friendsOnlineStatus : [Bool] = []
    
    
    
    // MARK: Searching users
    
    /**
     Find users by substring name.
     
     - Remark: Will try to find the users with the entered substring name.
     */
    func findUser() {
        resultUsers.removeAll()
        AppDelegate._bc.friendService.findUsers(bySubstrName: userName, maxResults: 10, completionBlock: onFoundUser, errorCompletionBlock: nil, cbObject: nil)
        
        Analytics.shared.screen("Find user")
    }
    
    func onFoundUser(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        //        print("\(serviceOperation!) Success \(jsonData!)")
        
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            // Make sure the results lists are empty first
            
            
            let json = JSON(jsonData)
            let data = json["data"]
            
            let resultsCount = data["matchedCount"].intValue
            if resultsCount == 0{
                hasResult = false // No users found!
            } else {
                
                // Matched search results sorted by name.
                let matchedResults = data["matches"].arrayValue
                    .sorted{ $0["profileName"].stringValue > $1["profileName"].stringValue }
                
                for result in matchedResults {
                    let profileId = result["profileId"].stringValue
                    if let otherUsersBlocks = result["summaryFriendData"]["blockedUsers"].arrayObject as? [String]{
                        if otherUsersBlocks.contains(currentUserID){
                            if resultsCount == 1{
                                hasResult = false
                            }
                            continue
                        }
                    }
                    
                    if !UserDefaults.standard.getBlockedUsers().contains(profileId){
                        let name = result["profileName"].stringValue
                        var picture = result["pictureUrl"].stringValue
                        if picture.isEmpty { picture = defaultProfPic }
                        
                        let res = ResultUser(profileId: profileId, name: name, picture: picture)
                        if !resultUsers.contains(res){
                            resultUsers.append(res)
                        }
                        hasResult = true
                    }
                }
            }
        }
    }
    
    // MARK: Friends
    
    /**
     Add the user as a friend.
     
     - Remark: Will try to add the selected user as a friend to the friends list.
     */
    func addFriend(profileIndex: Int = 0, id: String = "", shouldList: Bool = true) {
        
        var profileId: [String] = []
        
        if !id.isEmpty {
            profileId = [id]
        } else {
            profileId = [self.resultUsers[profileIndex].profileId]
        }
        
        AppDelegate._bc.friendService.addFriends(profileId, completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
        
        if shouldList{
            listFriends()
        }
        
        Analytics.shared.screen("Friend request sent")
    }
    
    
    /**
     List user's friends.
     
     - Remark: Will list all the current user's friends, includes facebook friends who are registered in the app.
     */
    func listFriends(){
        AppDelegate._bc.friendService.listFriends(FriendPlatformObjc(value: "All"), includeSummaryData: true, completionBlock: onFriendsList, errorCompletionBlock: nil, cbObject: nil)
    }
    
    func onFriendsList(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        //        print("\(serviceOperation!) Success \(jsonData!)")
        
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let json = JSON(jsonData)
            
            // Friends list sorted by name.
            let friendsJson = json["data"]["friends"].arrayValue.sorted
            { $0["name"].stringValue > $1["name"].stringValue }
            
            if self.friends.count != friendsJson.count{
                friends.removeAll()
                
                for friend in friendsJson{
                    let profileId = friend["playerId"].stringValue
                    let name = friend["name"].stringValue
                    var picture = friend["pictureUrl"].stringValue
                    if picture.isEmpty { picture = defaultProfPic }
                    
                    let friend = Friend(profileId: profileId, name: name, picture: picture)
                    if !friends.contains(friend){
                        friends.append(friend)
                    }
                }
                
                if UserDefaults.standard.getFriends() != friends{
                    UserDefaults.standard.setfriends(friends: friends)
                }
            }
        }
        
        self.loadingFriends = false
        
    }
    
    ///Checks if the recived users are online or not, and list the results on 'friendsOnlineStatus' list.
    func checkFriendsStatus(){
        if !friends.isEmpty{
            var profileIds: [String] = []
            
            for friend in friends{
                profileIds.append(friend.profileId)
            }
            
            AppDelegate._bc.friendService.getUsersOnlineStatus(profileIds, completionBlock: onChecked, errorCompletionBlock: nil, cbObject: nil)
        }
    }
    
    func onChecked(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let json = JSON(jsonData)
            
            let onlineStatus = json["data"]["onlineStatus"].arrayValue
            friendsOnlineStatus = onlineStatus.map { $0["isOnline"].boolValue }
        }
    }
    
    func removeFriend(_ profileId: String){
        AppDelegate._bc.getBCClient()?.friendService.removeFriends([profileId], completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
        
        self.friends.removeAll { (friend) -> Bool in
            friend.profileId == profileId
        }
    }
    
    func blockUser(_ profileId: String){
        var currentBlocked = UserDefaults.standard.getBlockedUsers()
        currentBlocked.append(profileId)
        
        let summaryData = "{\"blockedUsers\":\(currentBlocked)}"
        
        AppDelegate._bc.getBCClient()?.friendService.removeFriends([profileId], completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
        
        AppDelegate._bc.getBCClient()?.playerStateService.updateSummaryFriendData(summaryData, completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
        
        self.friends.removeAll { (friend) -> Bool in
            friend.profileId == profileId
        }    
        
        UserDefaults.standard.setBlockedUsers(ids: currentBlocked)
    }
}


struct ResultUser: Equatable {
    var profileId: String
    var name: String
    var picture: String
}

struct Friend: Codable, Equatable {
    var profileId: String
    var name: String
    var picture: String
}
