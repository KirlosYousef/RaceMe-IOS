//
//  TabsViews.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 12..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct MatchTabView: View {
    
    @EnvironmentObject var matchmaking : Matchmaking
    
    var body: some View{
        MatchView(progress:  ProgressObserver(matchId: self.matchmaking.runnersIDs, profPicsForID: self.matchmaking.runnersIdPics, chosenDistance: Double(self.matchmaking.chosenDistance))).environmentObject(matchmaking.match).environmentObject(matchmaking)
    }
}

struct ProfileTabView: View {
    
    @EnvironmentObject var login : Login
    
    var body: some View{
        ProfileView()
            .environmentObject(login)
            .onAppear(perform: {
                Analytics.shared.screen("Profile View")
            })
            .tabItem{
                VStack{
                    Image(systemName: "person.crop.circle.fill").font(Font.title.weight(.ultraLight))
                    
                    Text("Profile")
                }
        }
    }
}

struct StartMatchTabView: View {
    
    @EnvironmentObject var matchmaking : Matchmaking
    
    var body: some View{
        StartMatchView().environmentObject(matchmaking)
            .onAppear(perform: {
                Analytics.shared.screen("Start Match View")
            })
            .tabItem{
                VStack{
                    Image(systemName: "hare.fill").font(Font.title.weight(.ultraLight))
                    
                    Text("Run")
                }
        }
    }
}


struct FriendsTabView: View {
    
    let friends = Friends()
    
    var body: some View{
        FriendsView().environmentObject(friends)
            .onAppear(perform: {
                Analytics.shared.screen("Friends View")
            })
            .tabItem{
                VStack{
                    Image(systemName: "person.3.fill").font(Font.title.weight(.ultraLight))
                    
                    Text("Friends")
                }
        }
    }
}
