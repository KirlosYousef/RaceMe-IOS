//
//  StartMatchView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 12. 20..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct StartMatchView: View {
    
    @EnvironmentObject var matchmaking: Matchmaking
    @State private var chosenDistance: Int = 1000
    @State private var didChose: Bool = false
    @State private var didPressToken: Bool = false
    @State private var tokensBalance: String = "..."
    @State private var freeTokensBalance: String = "..."
    private let distanceList: [Double] = [1000, 2000, 3000, 4000, 5000]
    
    var body: some View {
        VStack{
            if self.didPressToken{
                ProductsView(didChoose: self.$didPressToken, tokensBalance: self.$tokensBalance)
            } else{
                NavigationView{
                    ZStack{
                        Image("Map")
                            .resizable()
                            .edgesIgnoringSafeArea(.top)
                        
                        VStack{
                            //                    Spacer()
                            Text("Choose a track to run!")
                                .font(Font.largeTitle)
                                .fontWeight(.light)
                                .padding(.top, OneThirdScreenHeight / 3)
                            Spacer()
                        }
                        
                        // Navigate to the matchmakeing when the user choose a distance.
                        NavigationLink(destination: MatchmakingView(chosenDistance: chosenDistance, didChose: $didChose, tokensBalance: self.$tokensBalance).environmentObject(matchmaking), isActive: $didChose) {
                            Text("")
                        }
                        
                        VStack{
                            Spacer()
                            VStack(alignment: .trailing){
                                Text("Weekly")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(.systemBlue))
                                HStack{
                                    Text(freeTokensBalance)
                                        .foregroundColor(Color(.systemBlue))
                                        .font(.title)
                                        .fontWeight(.medium)
                                    
                                    Image("FreeToken")
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 35, height: 35)
                                }
                                
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        self.didPressToken = true
                                    }) {
                                        Text("+")
                                            .foregroundColor(Color(.systemYellow))
                                            .font(.title)
                                            .fontWeight(.black)
                                        
                                        TokensBalanceView(tokensBalance: self.$tokensBalance, freeTokensBalance: self.$freeTokensBalance)
                                        //                                            .padding(.trailing)
                                    }
                                }
                            }
                            .padding(.trailing)
                            VStack{
                                Divider()
                                HStack{
                                    ForEach(0..<3, id: \.self){ distanceInd in
                                        
                                        DistanceButton(distanceInMeters: self.distanceList[distanceInd], chosenDistance: self.$chosenDistance, didChose: self.$didChose)
                                    }
                                }
                                Divider()
                                HStack{
                                    ForEach(3..<distanceList.count, id: \.self){ distanceInd in
                                        
                                        DistanceButton(distanceInMeters: self.distanceList[distanceInd], chosenDistance: self.$chosenDistance, didChose: self.$didChose)
                                    }
                                    
                                }
                                Divider()
                                
                                Text("Always remember you should run at a speed that allows you to hold a conversation.")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .padding()
                            }
                            .background(Color(.systemBackground))
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                    .navigationBarHidden(true)
                }
            }
        }
    }
}


struct DistanceButton: View {
    
    let distanceInMeters: Double
    @Binding var chosenDistance: Int
    @Binding var didChose: Bool
    
    var body: some View {
        HStack{
            
            Spacer()
            
            Button(action: {
                self.chosenDistance = Int(self.distanceInMeters)
                self.didChose = true
            }) {
                VStack{
                    Text("Track \(Int(distanceInMeters) / 1000 )") // To get the first digit of the int (1 if 1000).
                        .font(Font.headline)
                        .foregroundColor(Color(.label))
                    
                    Text(FormatDisplay.getDistanceWith(meters: distanceInMeters))
                        .font(Font.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            
            Spacer()
            
        }.padding()
    }
}


struct StartMatchView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            StartMatchView().environmentObject(Matchmaking())
            StartMatchView().environmentObject(Matchmaking())
                .environment(\.colorScheme, .dark)
        }
    }
}
