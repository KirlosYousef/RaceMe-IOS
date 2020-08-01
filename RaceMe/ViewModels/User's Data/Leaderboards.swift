//
//  Leaderboards.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 03. 26..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import SwiftyJSON

class Leaderboards: ObservableObject{
    
    @Published var leaderboards = [Leaderboard]()
    let friendsLeaderboardsIds: [String] = ["WeeklyFriendsLeaderboard",
                                            "MonthlyFriendsLeaderboard",
                                            "YearlyFriendsLeaderboard"]
    private let types = ["Weekly", "Monthly", "Yearly"]
    
    
    /// For testing
    //                init() {
    //                    var players = [LeaderboardPlayer(playerId: "1", playerName: "Kirlos", pictureUrl: defaultProfPic, score: 100),
    //                    LeaderboardPlayer(playerId: "2", playerName: "Kirlos E. Asaad", pictureUrl: defaultProfPic, score: 50),
    //                    LeaderboardPlayer(playerId: "3", playerName: "You", pictureUrl: defaultProfPic, score: 30),
    //                    LeaderboardPlayer(playerId: "4", playerName: "Test1", pictureUrl: defaultProfPic, score: 150),
    //                    LeaderboardPlayer(playerId: "5", playerName: "Test2", pictureUrl: defaultProfPic, score: 20)]
    //
    //                    players.sort { $0.score > $1.score }
    //
    //                    leaderboards.append(Leaderboard(id: "WeeklyFriendsLeaderboard", type: "Weekly", players: players))
    //                }
    
    func getFriendsLeaderboards(){
        AppDelegate._bc.leaderboardService.getMultiSocialLeaderboard(friendsLeaderboardsIds, leaderboardResultCount: 10, replaceName: true, completionBlock: onGotLeaderboard, errorCompletionBlock: nil, cbObject: nil)
        
    }
    
    func onGotLeaderboard(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            
            let json = JSON(jsonData)
            let jsonLeaderboards = json["data"]["leaderboards"].arrayValue
            leaderboards.removeAll()
            for jsonLeaderboard in jsonLeaderboards{
                let leaderboardId = jsonLeaderboard["leaderboardId"].stringValue
                let leaderboardPlayers = jsonLeaderboard["leaderboard"].arrayValue
                var players = [LeaderboardPlayer]()
                
                for player in leaderboardPlayers {
                    let playerId = player["playerId"].stringValue
                    let playerName = player["playerName"].stringValue
                    var pictureUrl = player["pictureUrl"].stringValue
                    if pictureUrl.isEmpty { pictureUrl = defaultProfPic }
                    let score = player["score"].intValue
                    
                    let leaderboardPlayer = LeaderboardPlayer(playerId: playerId, playerName: playerName, pictureUrl: pictureUrl, score: score)
                    if !players.contains(leaderboardPlayer){
                        players.append(leaderboardPlayer)
                    }
                }
                
                var leaderboardType = ""
                
                for type in types{
                    if leaderboardId.contains(type){ // For example id DailyFriendsLeaderboard contains type Daily
                        leaderboardType = type.uppercased()
                    }
                }
                
                players.sort { $0.score > $1.score }
                
                let leaderboard = Leaderboard(id: leaderboardId, type: leaderboardType, players: players)
                if !leaderboards.contains(leaderboard){
                    leaderboards.append(leaderboard)
                }
            }
        }
    }
}

struct LeaderboardPlayer: Equatable {
    var playerId: String
    var playerName: String
    var pictureUrl: String
    var score: Int
}

struct Leaderboard: Equatable {
    var id: String
    var type: String
    var players: [LeaderboardPlayer]
}
