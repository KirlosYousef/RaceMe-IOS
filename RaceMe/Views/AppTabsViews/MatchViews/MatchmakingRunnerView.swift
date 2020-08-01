//
//  MatchmakingRunnerView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 17..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct MatchmakingRunnerView: View {
    
    let runnerNum: Int
    @EnvironmentObject var matchMaking: Matchmaking
    
    var body: some View {
        HStack{
            if self.matchMaking.lobbyFull{
                //                Spacer()
                // The profile picture of the runner
                KFImageView(picURL: self.matchMaking.runnersPics[runnerNum], imageWidth: screenWidth / 7, imageHeight: screenWidth / 7)
                    .padding(5)
                
                // Runner's name
                VStack(alignment: .leading){
                    Text(matchMaking.runnersNames[runnerNum])
                        .font(Font.headline)
                        .foregroundColor(Color(.secondaryLabel))
                    
                    Text("XP: \(String(self.matchMaking.runnersRating[runnerNum]))")
                        .font(Font.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                    
                    // TO DO
                    //                    Text("Location: Sohag, Egypt")
                    //                        .font(Font.subheadline)
                    //                        .foregroundColor(Color(.secondaryLabel))
                }
                Spacer()
                VStack{
                    if self.matchMaking.runnersReadyStatus[runnerNum]{
                        Image(systemName: "bolt.circle.fill")
                            .font(Font.title.weight(.regular))
                            .foregroundColor(Color(.secondaryLabel))
                        Text("Ready")
                            .font(Font.caption)
                            .foregroundColor(Color(.secondaryLabel))
                    } else {
                        Image(systemName: "bolt.circle")
                            .font(Font.title.weight(.regular))
                            .foregroundColor(Color(.secondaryLabel))
                        Text("Not ready")
                            .font(Font.caption)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }.padding([.trailing, .leading])
    }
}

struct MatchmakingRunnerView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MatchmakingRunnerView(runnerNum: 0)
                .environmentObject(Matchmaking())
            MatchmakingRunnerView(runnerNum: 0)
                .environmentObject(Matchmaking())
                .environment(\.colorScheme, .dark)
        }
    }
}
