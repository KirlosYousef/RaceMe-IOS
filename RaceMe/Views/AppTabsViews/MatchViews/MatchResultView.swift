//
//  MatchResultView.swift
//  
//
//  Created by Kirlos Yousef on 2020. 03. 07..
//

import SwiftUI
import Analytics

///This view appears after the match ends, and it shows different data for the winner and the loser.
struct MatchResultView: View {
    
    @EnvironmentObject var matchmaking: Matchmaking
    @State var winner: String
    @State private var firstPColor: Color = Color(.secondaryLabel)
    @State private var secondPColor: Color = Color(.secondaryLabel)
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                Spacer()
                VStack{
                    if currentUserID == winner {
                        WinnerView().environmentObject(matchmaking)
                    } else {
                        LoserView().environmentObject(matchmaking)
                    }
                }.padding(.top, 20)
                Spacer()
                
                HStack{
                    Spacer()
                    
                    VStack{
                        
                        KFImageView(picURL: self.matchmaking.runnersPics[0], imageWidth: screenWidth / 5, imageHeight: screenWidth / 5, lineWidth: 5, strokeColor: firstPColor)
                        HStack{
                            
                            // Add friend button
                            // If the user is not the current user then show the add friend button!
                            if (currentUserID != self.matchmaking.runnersIDs[0])
                            {
                                if self.matchmaking.runnersIDs[0] != "BOT"{
                                    AddFriendButton(runnerId: self.matchmaking.runnersIDs[0])
                                }
                            }
                            
                            Text(self.matchmaking.runnersNames[0])
                                .font(Font.title)
                                .fontWeight(.light)
                                .foregroundColor(firstPColor)
                        }
                    }
                    
                    Spacer()
                    
                    VStack{
                        
                        KFImageView(picURL: self.matchmaking.runnersPics[1], imageWidth: screenWidth / 5, imageHeight: screenWidth / 5, lineWidth: 5, strokeColor: secondPColor)
                        HStack{
                            Text(self.matchmaking.runnersNames[1])
                                .font(Font.title)
                                .fontWeight(.light)
                                .foregroundColor(secondPColor)
                            
                            // Add friend button
                            // If the user is not the current user then show the add friend button!
                            if (currentUserID != self.matchmaking.runnersIDs[1])
                            {
                                if self.matchmaking.runnersIDs[1] != "BOT"{
                                    AddFriendButton(runnerId: self.matchmaking.runnersIDs[1])
                                }
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .onAppear(perform: {
                if self.matchmaking.runnersIDs[0] == self.winner{
                    self.firstPColor = darkBackground
                }else{
                    self.secondPColor = darkBackground
                }
            })
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea([.top, .bottom])
        }
        .onAppear(perform: {
            Analytics.shared.screen("Match Result View")
        })
    }
}

struct MatchResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MatchResultView(winner: currentUserID).environmentObject(Matchmaking()).environment(\.colorScheme, .dark)
            MatchResultView(winner: currentUserID).environmentObject(Matchmaking()).environment(\.colorScheme, .light)
        }
    }
}
struct AddFriendButton: View {
    
    @State var runnerId: String
    
    var body: some View {
        Button(action: {
            Friends().addFriend(id: self.runnerId)
        }) {
            Image(systemName: "person.badge.plus.fill")
                .foregroundColor(darkBackground)
                .font(Font.callout)
        }
    }
}

struct WinnerView: View {
    
    @EnvironmentObject var matchmaking: Matchmaking
    
    var body: some View {
        
        VStack{
            Spacer()
            
            Text("YOU MADE IT!")
                .font(Font.largeTitle)
                .fontWeight(.light)
            
            Spacer()
            
            Image("Winner-Icon")
            
            Spacer()
            
            Text("You have earned 50 XP!")
                .font(Font.callout)
            
            Spacer()
            
            HStack{
                Spacer()
                
                Button(action: {
                    self.matchmaking.matchStarted = false
                }) {
                    Text("SKIP")
                }.font(Font.headline)
                    .frame(width: 100, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(darkBackground, lineWidth: 1)
                )
                
                Spacer()
                
                // TO DO 
                //                Button(action: {
                //                }) {
                //                    Text("SHARE")
                //                }.font(Font.headline)
                //                    .foregroundColor(.white)
                //                    .frame(width: 100, height: 50)
                //                    .background(darkBackground)
                //                    .cornerRadius(5)
                //
                //                Spacer()
            }
            Spacer()
        }
        .frame(width: screenWidth - 50, height: OneThirdScreenHeight * 2)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color(.secondaryLabel).opacity(0.2), radius: 30, x: 0, y: 20)
    }
}

struct LoserView: View {
    
    @EnvironmentObject var matchmaking: Matchmaking
    
    var body: some View {
        VStack{
            Spacer()
            
            Text("YOU CAN DO IT NEXT TIME!")
                .font(Font.title)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Image("Loser-Icon")
            
            Spacer()
            
            Text("You still have earned 10 XP!")
                .font(Font.callout)
            
            Spacer()
            
            HStack{
                Spacer()
                
                Button(action: {
                    self.matchmaking.matchStarted = false
                }) {
                    Text("SKIP")
                }.font(Font.headline)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 50)
                    .background(darkBackground)
                    .cornerRadius(5)
                
                Spacer()
            }
            Spacer()
        }
        .frame(width: screenWidth - 50, height: OneThirdScreenHeight * 2)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color(.secondaryLabel).opacity(0.2), radius: 30, x: 0, y: 20)
    }
}
