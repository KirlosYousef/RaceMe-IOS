//
//  Statistics.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 03. 22..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation

/// This class is responsible for the user's and the app's Statistics.
class MatchData: ObservableObject{
    
    /**
     Atomically increment user statistics using the StoreMatchData. User statistics are defined through the brainCloud portal.
     A Notification will be sent to both of the players at the end of the script.
     
     - Parameters:
     - didWin: *1* if the current player is the winner, *0* if the loser.
     - secondsRun: The time the user has ran so far in seconds.
     - distance: The total distance the user ran in meters.
     */
    func storeMatchData(didWin: Int = 0, secondsRun: Int = 0, distance: Double = 0){
        let jsonScriptData = "{ \"didWin\": \"\(didWin)\", \"secondsRun\": \"\(secondsRun)\", \"distance\": \(distance)}"
        
        AppDelegate._bc.getBCClient()?.scriptService.run("StoreMatchData", jsonScriptData: jsonScriptData, completionBlock: nil, errorCompletionBlock: nil, cbObject: nil)
    }
}
