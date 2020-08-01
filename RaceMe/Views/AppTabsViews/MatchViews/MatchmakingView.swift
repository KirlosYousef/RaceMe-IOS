//
//  MatchmakingView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 12. 19..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI

/// The view that appears after the user choose a distance to run!
struct MatchmakingView: View {
    
    @State var chosenDistance: Int
    @State var showAlert: Bool = false
    @Binding var didChose: Bool
    @Binding var tokensBalance: String
    @EnvironmentObject var matchMaking: Matchmaking
    var body: some View {
        VStack{
            if self.matchMaking.hasTokens{
                ZStack(alignment: .bottom){
                    Image("Map")
                        .resizable()
                    
                    if self.matchMaking.locationAuthorized{
                        VStack{
                            
                            MatchMakingTopView(chosenDistance: self.$chosenDistance)
                            
                            VStack{
                                
                                Text(self.matchMaking.operationStatus)
                                    .font(Font.caption)
                                    .fontWeight(.light)
                                    .foregroundColor(Color(.secondaryLabel))
                                
                                Spacer()
                                
                                if matchMaking.lobbyFull{
                                    if (matchMaking.runnersReadyStatus[0] && matchMaking.runnersReadyStatus[1]) {
                                        MatchStartingView()
                                    } else {
                                        RunnersViews()
                                    }
                                }
                                else if self.matchMaking.roomCanceled{
                                    
                                    RoomCanceledView()
                                    
                                } else {
                                    Text("Searching for opponent...")
                                        .font(Font.body)
                                        .fontWeight(.light)
                                        .foregroundColor(Color(.secondaryLabel))
                                        .padding()
                                }
                                
                                if (self.matchMaking.canCancelLobby){
                                    CanCancelLobbyView(didChose: self.$didChose)
                                }
                                
                                Spacer()
                                
                            }
                            .frame(width: screenWidth)
                            .background(Color(.systemBackground))
                            .frame(minHeight: matchMaking.lobbyFull ? OneThirdScreenHeight * 2 : OneThirdScreenHeight * 2)
                            .animation(.spring())
                        }
                    } else {
                        Text("")
                            .onAppear {
                                self.showAlert = true
                        }
                    }
                }.modifier(MatchmakingModifier(chosenDistance: self.$chosenDistance, showAlert: self.$showAlert, didChose: self.$didChose))
            }
            else {
                ProductsView(didChoose: self.$didChose, tokensBalance: self.$tokensBalance)
                    .navigationBarBackButtonHidden(true)
                    .onDisappear {
                        self.matchMaking.hasTokens = true
                }
            }
        }
    }
}

private struct MatchmakingModifier: ViewModifier {
    
    @Binding var chosenDistance: Int
    @Binding var showAlert: Bool
    @Binding var didChose: Bool
    @EnvironmentObject var matchMaking: Matchmaking
    
    func body(content: Content) -> some View {
        ZStack{
            content
                .edgesIgnoringSafeArea(.top)
                .navigationBarBackButtonHidden(true)
                .onAppear(perform: {
                    self.matchMaking.askAuth()
                    self.matchMaking.chosenDistance = self.chosenDistance // For the lobby.
                    self.matchMaking.match.chosenDistance = Double(self.chosenDistance)
                })
                
                .alert(isPresented: $showAlert) {
                    if !self.matchMaking.locationAuthorized{
                        
                        let alertTitle = "Location Not authorized!"
                        let alertMessage = "RaceMe needs the access to your location to be able to track your run! You can allow it from Settings -> RaceMe -> Location."
                        
                        return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel({
                            self.didChose = false // To navigate back to StartMatchView
                            self.showAlert = false
                        }))
                    } else {
                        
                        let alertTitle = "Location authorized!"
                        let alertMessage = "Enjoy your race!"
                        
                        return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel(Text("Thank you!"), action: {
                            self.showAlert = false
                        }))
                    }
            }
        }
    }
}

private struct MatchMakingTopView: View{
    
    @Binding var chosenDistance: Int
    
    var body: some View{
        VStack{
            Spacer()
            
            Text("Track: \(String(chosenDistance / 1000))")
                .font(Font.largeTitle)
                .fontWeight(.light)
                .animation(.spring())
            
            Text("Distance to run: \(String(chosenDistance)) meters")
                .font(Font.caption)
                .fontWeight(.light)
                .animation(.spring())
            
            Spacer()
        }
    }
}

private struct RoomCanceledView: View {
    
    @EnvironmentObject var matchMaking: Matchmaking
    
    var body: some View{
        VStack{
            Text("Session timeout!")
                .font(Font.body)
                .fontWeight(.light)
                .foregroundColor(Color(.secondaryLabel))
                .padding()
                .onAppear {
                    self.matchMaking.canCancelLobby = true
            }
            Button(action: {
                self.matchMaking.askAuth()
            }, label: {
                Text("Retry")
                    .font(Font.body)
                    .fontWeight(.light)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 220, height: 50)
                    .background(Color(.systemGray5))
                    .cornerRadius(5.0)
            }).padding()
        }
    }
}

private struct RunnersViews: View{
    
    @EnvironmentObject var matchMaking: Matchmaking
    
    var body: some View {
        VStack{
            MatchmakingRunnerView(runnerNum: 0).environmentObject(matchMaking)
            
            Text("VS")
                .font(Font.title)
                .fontWeight(.heavy)
                .foregroundColor(Color(.secondaryLabel))
            
            MatchmakingRunnerView(runnerNum: 1).environmentObject(matchMaking)
            
            Button(action: {
                self.matchMaking.currentRunnerState.toggle()
                self.matchMaking.updateReady()
            }, label: {
                Text("Ready")
                    .font(Font.title)
                    .fontWeight(.light)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 220, height: 50)
                    .background(Color(.systemGray5))
                    .cornerRadius(5.0)
            }).padding()
        }
    }
}

private struct CanCancelLobbyView: View {
    
    @Binding var didChose: Bool
    @EnvironmentObject var matchMaking: Matchmaking
    
    var body: some View{
        Button(action: {
            self.didChose = false // To navigate back to StartMatchView
            
            if self.matchMaking.lobbyFull{
                self.matchMaking.LeaveLobby()
            } else {
                self.matchMaking.CancelFindRequest()
            }
        }, label: {
            Text("Cancel")
                .font(Font.callout)
                .frame(width: 120, height: 30)
                .foregroundColor(Color(.secondaryLabel))
                .background(Color(.systemGray5))
                .cornerRadius(5.0)
                .padding(.bottom)
            
        })
    }
}

private struct MatchStartingView: View {
    var body: some View{
        VStack{
            Text("Getting ready...")
                .font(Font.title)
                .fontWeight(.medium)
                .foregroundColor(Color(.secondaryLabel))
            
            Text("The match will start soon!")
                .font(Font.title)
                .fontWeight(.light)
                .foregroundColor(Color(.secondaryLabel))
                .padding()
                .padding(.bottom, 50)
        }
    }
}

struct MatchmakingView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MatchmakingView(chosenDistance: 1000, didChose: .constant(true), tokensBalance: .constant("0"))
                .environmentObject(Matchmaking())
            MatchmakingView(chosenDistance: 1000, didChose: .constant(true), tokensBalance: .constant("0"))
                .environmentObject(Matchmaking())
                .environment(\.colorScheme, .dark)
        }
    }
}
