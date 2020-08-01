//
//  MilestonesAndAchievements.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 03. 25..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import BrainCloud
import SwiftyJSON


/// This class is responsible for the user's milestones and achievements.
class MilestonesAndAchievements: ObservableObject{
    
    @Published var milestones = [Milestone]()
    
    /// For testing
    //        init() {
    //            milestones = [Milestone(id: 1, title: 1, requirement: 0, category: "MatchesWon", status: "SATISFIED", description: "Awarded after winning 10 matches.", xpRewards: 25),
    //                          Milestone(id: 2, title: 2, requirement: 1, category: "MatchesWon", status: "IN_PROGRESS", description: "Awarded after winning 10 matches.", xpRewards: 25),
    //                          Milestone(id: 3, title: 3, requirement: 100, category: "MatchesWon", status: "LOCKED", description: "Awarded after winning 10 matches.", xpRewards: 25),
    //                          Milestone(id: 4, title: 1, requirement: 0, category: "RunDistance", status: "SATISFIED", description: "Awarded after winning 10 matches.", xpRewards: 25),
    //                          Milestone(id: 5, title: 2, requirement: 100, category: "RunDistance", status: "IN_PROGRESS", description: "Awarded after winning 10 matches.", xpRewards: 25),
    //                          Milestone(id: 6, title: 3, requirement: 2, category: "RunDistance", status: "LOCKED", description: "Awarded after winning 10 matches.", xpRewards: 25)]
    //    
    //            self.milestones.sort { $0.title < $1.title }
    //        }
    
    
    func ReadMilestones(){
        AppDelegate._bc.gamificationService.readMilestones(true, completionBlock: onReadMilestones, errorCompletionBlock: nil, cbObject: nil)
    }
    
    func onReadMilestones(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?){
        if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let json = JSON(jsonData)
            let data = json["data"]
            let jsonMilestones = data["milestones"].arrayValue
            
            milestones.removeAll()
            
            for jsonMilestone in jsonMilestones{
                let id = jsonMilestone["milestoneId"].intValue
                let title = jsonMilestone["title"].intValue
                let category = jsonMilestone["category"].stringValue
                
                var stat = "distanceRun"
                if category == "MatchesWon"{
                    stat = "matchesWon"
                }
                
                let requirement = jsonMilestone["thresholds"]["playerStatistics"]["statistics"][stat].intValue
                let status = jsonMilestone["status"].stringValue
                let description = jsonMilestone["description"].stringValue
                let xpRewards = jsonMilestone["rewards"]["experiencePoints"].intValue
                
                let milestone = Milestone(id: id, title: title, requirement: requirement, category: category, status: status, description: description, xpRewards: xpRewards)
                
                if !self.milestones.contains(milestone){
                    self.milestones.append(milestone)
                }
            }
            self.milestones.sort { $0.title < $1.title }
        }
    }
}

struct Milestone: Equatable {
    var id: Int
    var title: Int
    var requirement: Int
    var category: String
    var status: String
    var description: String
    var xpRewards: Int
}
