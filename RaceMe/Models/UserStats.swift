//
//  UserStats.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation

struct UserStats {
    var level: Int
    var matchesPlayed: Int
    var matchesWon: Int
    var distanceRun: Int
    var dataFetched: Bool
    
    init(level: Int = 1,
         matchesPlayed: Int = 0,
         matchesWon: Int = 0,
         distanceRun: Int = 0,
         dataFetched: Bool = false) {
        
        self.level = level
        self.matchesPlayed = matchesPlayed
        self.matchesWon = matchesWon
        self.distanceRun = distanceRun
        self.dataFetched = dataFetched
    }
}
