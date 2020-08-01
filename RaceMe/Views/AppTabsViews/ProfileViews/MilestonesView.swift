//
//  MilestonesView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 03. 25..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct MilestonesView: View {
    
    @EnvironmentObject var milestones : MilestonesAndAchievements
    
    var body: some View {
        List{
            if !milestones.milestones.isEmpty{
                
                ForEach(milestones.milestones, id: \.id){ milestone in
                    VStack{
                        if milestone.category == "RunDistance"{
                            MilestoneView(milestone: milestone, progress: getUserData.userStats.distanceRun)
                        }
                        else if milestone.category == "MatchesWon"{
                            MilestoneView(milestone: milestone, progress: getUserData.userStats.matchesWon)
                        }
                    }
                    
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            self.milestones.ReadMilestones()
            getUserData.readUserState(milestones: self.milestones)
            Analytics.shared.screen("Milestones View")
        }
    }
}

struct MilestonesView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MilestonesView().environmentObject(MilestonesAndAchievements())
            MilestonesView().environmentObject(MilestonesAndAchievements())
                .environment(\.colorScheme, .dark)
        }
    }
}


struct MilestoneView: View {
    
    
    @State var milestone: Milestone
    @State var progress: Int = 0
    @State private var background: Color = darkBackground
    @State private var progressBackground: Color = darkBackground
    @State private var descColor: Color = Color(.secondaryLabel)
    @State private var isInProgress: Bool = false
    @State private var type: String = "Ran Marathons"
    
    var body: some View {
        HStack{
            
            ZStack{
                
                Circle()
                    .foregroundColor(background)
                    .frame(width: 100 / 2, height: 100 / 2)
                
                if isInProgress{
                    Circle()
                        .opacity(0.7)
                        .foregroundColor(progressBackground)
                        .frame(width: 100 / 2,height: CGFloat((Float(progress) / Float(milestone.requirement)) * 100) / 2)
                }
            }
            VStack(alignment: .leading){
                Text("\(milestone.title) " + type)
                    .font(Font.headline)
                    .foregroundColor(background)
                
                Text(milestone.description)
                    .font(Font.subheadline)
                    .foregroundColor(descColor)
            }
            Spacer()
            VStack{
                Text("XP")
                    .font(Font.headline)
                    .foregroundColor(background)
                
                Text("\(milestone.xpRewards)")
                    .font(Font.headline)
                    .foregroundColor(background)
            }
        }
        .padding()
        .onAppear {
            if self.milestone.category == "MatchesWon"{
                let matchesWonColor = Color(.systemGreen)
                self.background = matchesWonColor
                self.progressBackground = matchesWonColor
                self.type = "Won Matches"
            }
            if self.milestone.status == "LOCKED"{
                let lockedColor = Color(UIColor.systemGray5)
                self.background = lockedColor
                self.descColor = lockedColor
            }
            else if self.milestone.status == "IN_PROGRESS"{
                self.background = Color(.systemGray2)
                self.isInProgress = true
            }
            else if self.milestone.status == "UNLOCKED"{
                self.background = Color(.systemGray2)
            }
        }
        .animation(.easeIn)
    }
}
