//
//  Match.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 02. 21..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import BrainCloud
import SwiftyJSON
import Swift
import SwiftLocation
import CoreLocation

/// This class is responsible all the functions used in the match!
class Match: ObservableObject{
    private var lobbyId = ""
    private let locationManager = LocationManager.shared
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var locationRequest: LocationRequest? = nil
    private var seconds = 0
    private var matchEnded: Bool = false
    private var timer: Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }
    
    private var matchData = MatchData()
    private var isLobbyDisbanded = false
    
    @Published var formattedDistance: String = "0.000"
    @Published var formattedTime: String = "00:00:00"
    @Published var formattedPace: String = "0.000"
    @Published var chosenDistance: Double = 1000
    @Published var runnedPercentage: Int = 0
    
    /// Disbands the given lobby. msg and details are optional values.
    func disbandLobby(lobbyId: String){
        if !lobbyId.isEmpty && !isLobbyDisbanded{
            AppDelegate._bc.scriptService.run("DisbandLobby", jsonScriptData: "{\"lobbyId\":\"\(lobbyId)\",\"msg\":\"Game Ended!\"}", completionBlock: onRoomDisbanded, errorCompletionBlock: nil, cbObject: nil)
        }
    }
    
    func onRoomDisbanded(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        //                print("Server is Connected! \(serviceOperation!) Success \(jsonData!)")
        isLobbyDisbanded = true
        matchEnded = true
        resetRun()
    }
    
    /// The function to be called when the players are ready to run and the match starts!
    func startRun(lobbyId: String){
        resetRun()
        matchEnded = false
        isLobbyDisbanded = false
        locationManager.pausesLocationUpdatesAutomatically = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.seconds += 1
        }
        
        self.locationRequest = locationManager.locateFromGPS(.continous, accuracy: .room, activity: .fitness) { (result) in
            switch result {
            case .failure(let error):
                if !self.matchEnded && "\(error)" != "cancelled"{
                    self.disbandLobby(lobbyId: self.lobbyId) // disband The lobby immediately, the reason maybe the runner is using another way to move rather than running.
                    print("Received error: \(error)")
                }
                //                self.matchEnded = true
                
                self.timer?.invalidate()
                self.timer = nil
                
            case .success(let newLocation):
                if !self.matchEnded{
                    //                        print("Location received: \(newLocation)")
                    let howRecent = newLocation.timestamp.timeIntervalSinceNow
                    if newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 {
                        var outputUnit = UnitSpeed.minutesPerMile
                        if UserDefaults.standard.getDistanceUnit() != "Miles"{
                            outputUnit = UnitSpeed.minutesPerKilometer
                        }
                        if let lastLocation = self.locationList.last {
                            let delta = newLocation.distance(from: lastLocation)
                            self.distance = self.distance + Measurement(value: delta, unit: UnitLength.meters)
                        }
                        self.locationList.append(newLocation)
                        self.formattedDistance = FormatDisplay.getDistanceWith(meters: self.distance.value)
                        self.formattedTime = FormatDisplay.time(self.seconds)
                        self.formattedPace = FormatDisplay.pace(distance: self.distance,
                                                                seconds: self.seconds,
                                                                outputUnit: outputUnit)
                        
                        self.checkRun()
                    }
                    //                        print("\(self.runnedPercentage)%")
                } else{
                    self.locationRequest?.stop()
                }
            }
        }
    }
    
    /// Sets the runned percentage of the target distance!
    func checkRun(){
        // Converts the runned distance to percentage of the target distance.
        let runnedPercentage = Int((self.distance.value / self.chosenDistance) * 100)
        // Checks if it's less than 100 it will store it to be used by the UI.
        if runnedPercentage < 100 {
            self.runnedPercentage = runnedPercentage
        }
            // otherwise, it will store 100 to the variable and stop the location request.
        else if runnedPercentage >= 100 {
            self.runnedPercentage = 100
            self.locationRequest?.stop()
            //            self.matchEnded = true
            endMatch(winner: currentUserID)
        }
    }
    
    /// To set the match ended variable to true, disband the lobby and stops the location request!
    func endMatch(winner: String){
        
        self.locationRequest?.stop()
        if !self.matchEnded{
            self.timer?.invalidate()
            self.timer = nil
            
            //		print("The Winner is: \(winner)")
            self.matchEnded = true
            
            locationManager.backgroundLocationUpdates = false
            
            let didWin = (winner == currentUserID ? 1 : 0) // If the current user is the winner set the variable to 1
            matchData.storeMatchData(didWin: didWin, secondsRun: self.seconds, distance: self.distance.value)
            
            self.disbandLobby(lobbyId: lobbyId)
        }
    }
    
    /// Resets all the match data.
    func resetRun(){
        locationRequest?.stop()
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        locationRequest?.stop()
        formattedDistance = "0.000"
        formattedTime = "00:00:00"
        formattedPace = "0.000"
        seconds = 0
        matchEnded = false
        isLobbyDisbanded = false
        runnedPercentage = 0
        self.timer?.invalidate()
        self.timer = nil
    }
}
