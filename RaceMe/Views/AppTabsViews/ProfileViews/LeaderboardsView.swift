//
//  LeaderboardView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 03. 27..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct LeaderboardsView : View {
    
    @EnvironmentObject var leaderboards: Leaderboards
    @State var leaderboardInd: Int = 0
    
    var body: some View {
        VStack(alignment:.center){
            List{
                if leaderboards.leaderboards[leaderboardInd].players.count > 0 {
                    ForEach((0..<leaderboards.leaderboards[leaderboardInd].players.count), id: \.self){ playerInd in
                        // PLAYER
                        LBPlayer(player: self.leaderboards.leaderboards[self.leaderboardInd].players[playerInd], playerRank: playerInd)
                    }
                } else{
                    Text("Add some friends to be able to see the leaderboards!")
                }
            }
        }
    }
    
    struct LBPlayerView : View {
        
        @State var player: LeaderboardPlayer
        @State var playerRank: Int
        @State private var rankColor: Color = Color(.systemGray)
        @State private var rankSize: CGFloat = screenWidth / 5
        
        var body: some View {
            ZStack(alignment: .bottom){
                
                KFImageView(picURL: player.pictureUrl, imageWidth: rankSize, imageHeight: rankSize, lineWidth: 10, backgroundColor: rankColor)
                    .padding(5)
                
                Text(player.playerName)
                    .foregroundColor(Color(.label))
                    .font(Font.callout)
                    .frame(maxWidth: rankSize + 20, maxHeight: rankSize / 3)
                    .background(rankColor)
                    .offset(y: 5)
                
                Spacer()
            }
            .frame(height: OneThirdScreenHeight / 2)
            .onAppear {
                switch self.playerRank{
                case 0:
                    self.rankColor = Color(.systemOrange)
                    self.rankSize = screenWidth / 3.5
                    break
                case 1:
                    self.rankColor = Color(.systemYellow)
                    self.rankSize = screenWidth / 4
                    break
                case 2:
                    self.rankColor = Color(.systemTeal)
                    self.rankSize = screenWidth / 4.5
                    break
                default:
                    break
                }
            }
        }
    }
    
    struct LeaderboardsView_Previews: PreviewProvider {
        static var previews: some View {
            Group{
                LeaderboardsView(leaderboardInd: 0)
                    .environmentObject(Leaderboards())
                LeaderboardsView(leaderboardInd: 0)
                    .environmentObject(Leaderboards())
                    .environment(\.colorScheme, .dark)
            }
        }
    }
    
    struct LBPlayer : View {
        
        @State var player: LeaderboardPlayer
        @State var playerRank: Int
        @State private var rankColor: Color = Color(.systemGray)
        
        var body: some View {
            HStack(alignment: .center){
                Text("\(playerRank + 1)")
                    .font(Font.footnote)
                    .foregroundColor(rankColor)
                    .frame(width: 15)
                
                KFImageView(picURL: player.pictureUrl, imageWidth: screenWidth / 7, imageHeight: screenWidth / 7, lineWidth: 3, strokeColor: rankColor)
                    .padding()
                
                HStack(){
                    Text(player.playerName)
                        .foregroundColor(Color(.label))
                    
                    Spacer()
                    
                    VStack{
                        Text("SCORE")
                            .foregroundColor(Color(.secondaryLabel))
                            .font(Font.callout)
                        
                        Text("\(player.score)")
                            .foregroundColor(rankColor)
                            .font(Font.subheadline)
                    }
                }
                Spacer()
            }
            .onAppear {
                switch self.playerRank{
                case 0:
                    self.rankColor = Color(.systemRed)
                    break
                case 1:
                    self.rankColor = Color(.systemOrange)
                    break
                case 2:
                    self.rankColor = Color(.systemYellow)
                    break
                default:
                    break
                }
            }
        }
    }
}
