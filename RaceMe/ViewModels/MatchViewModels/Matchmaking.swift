//
//  Matchmaking.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 12. 20..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation
import BrainCloud
import SwiftyJSON
import SwiftLocation
import Fakery

/// The Matchmaking Service is used for locating players to play against when using the multiplayer features.
class Matchmaking: ObservableObject{
    
    @Published var lobbyId: String = ""
    @Published var operationStatus: String = "..."
    @Published var runnersIDs: [String] = []
    @Published var runnersNames: [String] = []
    @Published var runnersPics: [String] = []
    @Published var runnersIdPics = ["": ""]
    @Published var runnersRating: [Int] = []
    @Published var runnersReadyStatus: [Bool] = []
    @Published var currentRunnerState: Bool = false
    @Published var lobbyFull: Bool = false
    @Published var matchStarted: Bool = false
    @Published var roomCanceled: Bool = false
    @Published var canCancelLobby: Bool = false
    @Published var locationAuthorized: Bool = true
    @Published var hasTokens: Bool = true
    @Published var chosenDistance: Int = 1000
    @Published var match: Match = Match()
    private var cxId: String = ""
    private var lobbyType: String = ""
    private let faker = Faker(locale: "en")
    
    // MARK: Auth
    func askAuth(){
        self.resetData()
        if LocationManager.state.description == "available"{ // If the user allows the location service.
            self.locationAuthorized = true
            self.enableMatchmaking()
        } else {
            // If not, then ask for the authorization.
            LocationManager.shared.requireUserAuthorization(.whenInUse)
            
            // Observe any changes to the authorization.
            LocationManager.shared.onAuthorizationChange.add { (state) in
                if state.description == "denied"{
                    print("Not authorized!")
                    self.locationAuthorized = false
                    LocationManager.shared.onAuthorizationChange.removeAll()
                } else if state.description == "available" {
                    self.locationAuthorized = true
                    self.enableMatchmaking()
                    LocationManager.shared.onAuthorizationChange.removeAll()
                }
            }
        }
    }
    
    // MARK: Matchmaking
    
    /// Enables match making for the player.
    func enableMatchmaking(){
        AppDelegate._bc.scriptService.run("EnableMatchmaking", jsonScriptData: "{}", completionBlock: onMatchmakingEnabled, errorCompletionBlock: onMatchmakingError, cbObject: nil)
    }
    
    func onMatchmakingEnabled(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let json = JSON(jsonData)
            
            let response = json["data"]["response"]
            let isEnabled = response["isEnabled"].boolValue
            
            if isEnabled { // If Matchmaking has been enabled...
                
                enableRTT()
                
                findOrCreateLobby()
                
            } else {
                if let reason = response["reason"].string{
                    if reason == "No tokens"{
                        
                        self.hasTokens = false
                        print("You don't have enough tokens, please get some!")
                        
                    } else {
                        print(reason)
                    }
                }
            }
        }
        
    }
    
    func onMatchmakingError(serviceName:String?, serviceOperation:String?, firstVal: Int?, secondVal: Int?, jsonData:String?, cbObject: NSObject?){
        self.roomCanceled = true
    }
    
    /// Cancels any FindLobby or FindOrCreateLobby requests that have been previously submitted by the caller for the given lobbyType.
    func CancelFindRequest(){
        if !roomCanceled{
            AppDelegate._bc.scriptService.run("CancelFindRequest", jsonScriptData: "{ \"cxId\": \"\(cxId)\", \"lobbyType\": \"\(lobbyType)\" }", completionBlock: onLeftLobby, errorCompletionBlock: nil, cbObject: nil)
        }
    }
    
    // MARK: Lobby
    
    /// Finds a lobby matching the specified parameters, or creates one. Asynchronous - returns 200 to indicate that matchmaking has started.
    func findOrCreateLobby(){
        //        print("1v1_\(chosenDistance)")
        AppDelegate._bc.lobbyService.findOrCreateLobby("1v1_\(chosenDistance)", rating: 100, maxSteps: 1, algo: "{\"strategy\":\"ranged-absolute\",\"alignment\":\"center\",\"ranges\":[10,50,100]}", filterJson: "", otherUserCxIds: [], isReady: false, extraJson: "{\"cheater\":false}", teamCode: "", settings: "{}", completionBlock: onFoundOrCreated, errorCompletionBlock: nil, cbObject: "obj" as BCCallbackObject)
    }
    
    func onFoundOrCreated(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        //        print("\(serviceOperation!) Success \(jsonData!)")
        regLobbyCallBack()
    }
    
    /// Updates the ready status and extra json for the given lobby member.
    func updateReady(){
        AppDelegate._bc.lobbyService.updateReady(self.lobbyId, isReady: currentRunnerState, extraJson: "{}", completionBlock: onReadyUpdated, errorCompletionBlock: onReadyFailed, cbObject: "obj" as BCCallbackObject)
    }
    
    func onReadyUpdated(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        //		        print("READY! \(serviceOperation!) Success \(jsonData!)")
    }
    
    func onReadyFailed(serviceName:String?, serviceOperation:String?,firstInp: Int?,secondInp: Int?, jsonData:String?, cbObject: NSObject?){
        print("READY FAILED! \(serviceOperation!) Failed \(jsonData!)")
        self.resetData()
        self.roomCanceled = true
    }
    
    /// Causes the caller to leave the specified lobby. If the user was the owner, a new owner will be chosen. If user was the last member, the lobby will be deleted.
    func LeaveLobby(){
        if !lobbyId.isEmpty{
            AppDelegate._bc.lobbyService.leave(lobbyId, completionBlock: onLeftLobby, errorCompletionBlock: nil, cbObject: nil)
        }
    }
    
    func onLeftLobby(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        resetData()
    }
    
    /// Reset all the data to the default ones
    func resetData(){
        self.lobbyFull = false
        self.runnersIDs.removeAll()
        self.runnersNames.removeAll()
        self.runnersPics.removeAll()
        self.runnersIdPics.removeAll()
        self.runnersRating.removeAll()
        self.runnersReadyStatus.removeAll()
        self.currentRunnerState = false
        self.operationStatus = "..."
        self.lobbyId = ""
        self.canCancelLobby = false
        self.cxId = ""
        self.lobbyType = ""
        self.roomCanceled = false
        self.matchStarted = false
    }
    
    // MARK: RTT
    
    /// BrainCloud's new Real-Time Tech (RTT) featureset expands upon these capabilities - adding the ability for brainCloud to push information and updates to clients that need it.
    func enableRTT(){
        AppDelegate._bc.getBCClient()?.rttService.enable(nil, failureCompletionBlock: nil, cbObject: nil)
    }
    
    /// Registers a callback for RTT Lobby updates.
    func regLobbyCallBack(){
        AppDelegate._bc.getBCClient()?.rttService.registerLobbyCallback(onLobbyCalledBack, cbObject: nil)
    }
    
    func onLobbyCalledBack(jsonData:String?, cbObject: NSObject?){
        //        print("Lobby Call Back Success! \(jsonData!)")
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let json = JSON(jsonData)
            
            let lobbyType = json["data"]["lobbyType"].stringValue
            if lobbyType != "" {self.lobbyType = lobbyType}
            
            let cxId = json["data"]["member"]["cxId"].stringValue
            if !cxId.isEmpty {
                self.cxId = cxId
                self.canCancelLobby = true
            }
            
            operationStatus = json["operation"].stringValue
            switch operationStatus {
            case "STARTING": // If the match is starting and the lobbyId is not empty!
                if !lobbyId.isEmpty && currentUserID == runnersIDs[0]{ // The second condition to make sure that only one of the players calls the function
                    self.roomReady()
                }
                break
                
            case "DISBANDED": // If the lobby has been Disbanded
                let reason = json["data"]["reason"]
                let code = reason["code"].intValue
                if code == 80101{ // Room successfully launched!
                    //                    					self.matchStarted = true
                } else {
                    self.roomCanceled = true
                    self.lobbyFull = false
                    print(reason["desc"]) // Print the disband reason
                }
                break
                
            case "SIGNAL": // If received a signal using the sendSignal function
                let signalData = json["data"]["signalData"]
                print(signalData)
                break
                
            case "MATCHMAKING_IN_PROGRESS":
                break
                
            case "ROOM_READY":
                self.matchStarted = true
                break
                
            case "MEMBER_LEFT": // If the other member left the lobby, reset the data to be able to find another opponent!
                let data = json["data"]
                let lobbyOwner = data["lobby"]["owner"].stringValue
                if (lobbyOwner == currentUserID){
                    self.lobbyFull = false
                    let membersArray = data["lobby"]["members"].arrayValue
                    for mem in membersArray {
                        if mem["profileId"].stringValue == lobbyOwner{
                            self.cxId = mem["cxId"].stringValue
                        }
                    }
                } else {
                    self.roomCanceled = true
                }
                break
                
            case "STATUS_UPDATE":
                let state = json["data"]["lobby"]["state"].stringValue
                if state == "early" && self.runnersIDs.count == 1{
                    // If the user entered the 'early' state in the matchmaking and still did not find an opponent, a bot with fake data will be registered!
                    self.runnersNames.append(faker.name.name())
                    self.runnersIDs.append("BOT")
                    self.runnersPics.append(defaultProfPic)
                    
                    var ratting = faker.number.randomDouble(min: 250, max: 2500)
                    ratting = (round(ratting * 5) / 5)
                    self.runnersRating.append(Int(ratting))
                    
                    self.runnersReadyStatus.append(true)
                    self.runnersIdPics = [self.runnersIDs[0]: self.runnersPics[0], self.runnersIDs[1]: self.runnersPics[1]]
                    self.lobbyFull = true
                }
                break
                
            default: // Anything else
                let data = json["data"]
                
                self.lobbyId = data["lobbyId"].stringValue
                
                let lobby = data["lobby"]
                
                let numMembers = lobby["numMembers"].intValue
                
                // Members list sorted by name.
                let members = lobby["members"].arrayValue.sorted
                { $0["name"].stringValue > $1["name"].stringValue }
                
                if self.runnersIDs.contains("BOT") && numMembers != 2{ // If there is only a bot 
                    for (ind, id) in self.runnersIDs.enumerated(){
                        if id == currentUserID{
                            self.runnersReadyStatus[ind] = currentRunnerState
                        }
                    }
                }
                else{
                    // Set the data from JSON to the arrays.
                    self.runnersNames = members.map {$0["name"].stringValue}
                    self.runnersIDs = members.map {$0["profileId"].stringValue}
                    self.runnersPics = members.map
                        {$0["pic"].stringValue == "" ? defaultProfPic : $0["pic"].stringValue}
                    
                    
                    self.runnersRating = members.map {$0["rating"].intValue}
                    self.runnersReadyStatus = members.map {$0["isReady"].boolValue}
                    
                    if numMembers == 2{ // If the lobby has two members, then set it to full!
                        self.lobbyFull = true
                        self.runnersIdPics = [self.runnersIDs[0]: self.runnersPics[0], self.runnersIDs[1]: self.runnersPics[1]]
                    } else {
                        self.lobbyFull = false
                    }
                }
            }
        }
    }
    
    /// Tells the lobby system that a room server is ready to go.
    func roomReady(){
        if !lobbyId.isEmpty{
            AppDelegate._bc.scriptService.run("RoomReady", jsonScriptData: "{ \"lobbyId\": \"\(lobbyId)\", \"connectInfo\": {} }", completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
        }
    }
    
    /// Tells the server that the match has successfully started and currently running.
    func matchRunning(){
        AppDelegate._bc.scriptService.run("MatchStarted", jsonScriptData: "{}", completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
    }
}
