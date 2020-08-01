//
//  MatchView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 02. 21..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import Firebase
import Fakery
import Analytics

/**
 The view of the match with other user.
 
 - Remark: 'progressObserver' is required!
 */
struct MatchView: View {
    @ObservedObject var progress : ProgressObserver
    @EnvironmentObject var match: Match
    @EnvironmentObject var matchmaking: Matchmaking
    @State private var lastProgress: Int = 0
    @State private var distance = "0.000"
    @State private var time = "00:00:00"
    @State private var pace = "0.000"
    @State private var timer: Timer?
    @State private var showingSurrenderAlert = false
    
    
    private func isCurrnetPlayer(id: String) -> Bool{
        if id == UserDefaults.standard.getUserId(){
            return true
        }
        return false
    }
    
    var body: some View {
        HStack{
            if !progress.isMatchEnded{
                Spacer()
                
                ProgressBar(progress: $progress.progressData.firstRunnerProgress, profPic: progress.firstRPic, isCurrentPlayer: isCurrnetPlayer(id: progress.firstRunnerId))
                    .frame(width: 60)
                
                Spacer()
                
                VStack{
                    Spacer()
                    VStack{
                        Text("Time: \(time)")
                        
                        Text("Distance: \(distance)")
                        
                        Text("Pace: \(pace)")
                    }.frame(width: screenWidth/2)
                    
                    Spacer()
                    
                    Button(action: {
                        //                        self.progress.surrender()
                        self.showingSurrenderAlert.toggle()
                    }) {
                        Text("Surrender")
                            .font(Font.callout)
                            .frame(width: 120, height: 30)
                            .foregroundColor(Color(.secondaryLabel))
                            .background(Color(.systemGray5))
                            .cornerRadius(5.0)
                            .padding(.bottom)
                    }.alert(isPresented: $showingSurrenderAlert) {
                        Alert(title: Text("Are you sure you want to surrender?"), primaryButton: .default(Text("I'm sure"), action: {
                            self.progress.surrender()
                        }), secondaryButton: .cancel())
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                ProgressBar(progress: $progress.progressData.secondRunnerProgress, profPic: progress.secondRPic, isCurrentPlayer: isCurrnetPlayer(id: progress.secondRunnerId))
                    .frame(width: 60)
                
                Spacer()
                    .onAppear(perform: {
                        self.progress.isMatchEnded = false
                        self.match.startRun(lobbyId: self.matchmaking.lobbyId)
                        
                        
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            if !self.progress.isMatchEnded{
                                if self.lastProgress != self.match.runnedPercentage{
                                    self.progress.addprogress(progress: CGFloat(self.match.runnedPercentage))
                                    self.distance = self.match.formattedDistance
                                    
                                    self.lastProgress = self.match.runnedPercentage
                                }
                                self.pace = self.match.formattedPace
                                self.time = self.match.formattedTime
                            }
                            else { // If the match is ended
                                self.timer?.invalidate() // Stop the timer
                                self.match.endMatch(winner: self.progress.winner) // Call END function
                            }
                        }
                    })
            } else{
                // Match ended!
                MatchResultView(winner: self.progress.winner).environmentObject(self.matchmaking)
                    .onAppear {
                        if self.timer?.isValid ?? false{
                            self.timer?.invalidate() // Stop the timer
                            self.match.endMatch(winner: self.progress.winner) // Call END function
                        }
                }
            }
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .onAppear {
            self.matchmaking.matchRunning()
        }
    }
}

struct MatchView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MatchView(progress: ProgressObserver(matchId: ["Sender", "Reciver"], profPicsForID: [defaultProfPic:defaultProfPic, defaultProfPic:defaultProfPic], chosenDistance: 1000)).environmentObject(Match()).environmentObject(Matchmaking()).environment(\.colorScheme, .dark)
            
            MatchView(progress: ProgressObserver(matchId: ["Sender", "Reciver"], profPicsForID: [defaultProfPic:defaultProfPic, defaultProfPic:defaultProfPic], chosenDistance: 1000)).environmentObject(Match()).environmentObject(Matchmaking())
        }
    }
}


struct progressType{
    var firstRunnerProgress : CGFloat
    var secondRunnerProgress : CGFloat
}
