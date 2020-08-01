//
//  ProfileView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 31..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import SlidingTabView

// The view of the user's profile.
struct ProfileView: View {
    
    @EnvironmentObject var login: Login
    
    var body: some View {
        VStack{
            HStack(alignment: .top){
                PlayerProfileDataView()
                    .environmentObject(login)
                    .padding()
            }.frame(width: screenWidth, height: OneThirdScreenHeight / 2)
            Divider()
            
            StatDataView()
                .padding()
            
            Divider()
            
            Text("FRIENDS LEADERBOARD")
                .font(.callout)
                .foregroundColor(Color(.label))
                .padding()
            
            SlidingTabLeaderboardsView()
                .environmentObject(login.leaderboards)
            
        }
        .background(Color(.systemBackground))
        .onAppear {
            getUserData.readUserState(leaderboards: self.login.leaderboards)
        }
    }
}


#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView().environmentObject(Login()).environment(\.colorScheme, .light)
            ProfileView().environmentObject(Login()).environment(\.colorScheme, .dark)
        }
    }
}
#endif


struct PlayerProfileDataView : View {
    
    @State var showingSettings: Bool = false
    @State var showingMilestones: Bool = false
    @State private var uiImage: UIImage? = nil
    @State private var showAction: Bool = false
    @State private var showImagePicker: Bool = false
    @EnvironmentObject var login: Login
    
    var body: some View {
        GeometryReader{ geometry in
            HStack(){
                if !getUserData.currentUserData.image.isEmpty{
                    ProfilePictureEdit(uiImage: self.$uiImage, showAction: self.$showAction, showImagePicker: self.$showImagePicker, imageWidthAndHeight: geometry.size.width / 4)
                        .padding([.trailing, .top, .bottom])
                        .onTapGesture {
                            if getUserData.currentUserData.image != defaultProfPic{
                                self.showAction = true
                            } else{
                                self.showImagePicker = true
                            }
                    }
                }
                VStack{
                    HStack(){
                        Text(getUserData.currentUserData.userName)
                            .font(Font.system(.title))
                            .fontWeight(.light)
                        
                        Spacer()
                        Button(action: {
                            self.showingSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                                .font(Font.system(.headline))
                                .foregroundColor(Color(.label))
                            
                        }.sheet(isPresented: self.$showingSettings) {
                            MoreView().environmentObject(self.login)
                        }
                    }
                    
                    HStack{
                        Button(action: {
                            self.showingMilestones.toggle()
                        }) {
                            Image(systemName: "rosette")
                                .font(Font.system(.headline))
                            
                            Text("Milestones")
                                .font(Font.system(.callout))
                        }.sheet(isPresented: self.$showingMilestones) {
                            MilestonesView()
                                .environmentObject(self.login.milestonesAndAchievements)
                        }.foregroundColor(Color(.label))
                        
                        Spacer()
                    }
                }
            }
        }
    }
}


struct StatDataView : View {
    
    var body: some View {
        HStack{
            Spacer()
            VStack(spacing: 5){
                Text("LEVEL")
                    .font(Font.system(.callout))
                
                NumberView(number: getUserData.userStats.level)
            }
            Spacer()
            VStack(spacing: 5){
                Text("MATCHES")
                    .font(Font.system(.callout))
                
                NumberView(number: getUserData.userStats.matchesPlayed)
            }
            Spacer()
            VStack(spacing: 5){
                Text("WINS").font(Font.system(.callout))
                
                NumberView(number: getUserData.userStats.matchesWon)
            }
            Spacer()
        }
        .animation(.default)
    }
}


struct NumberView : View {
    @State var number: Int
    var body: some View {
        VStack() {
            Text("\(number)")
                .font(Font.system(.subheadline))
                .foregroundColor(Color(.systemBlue))
        }
    }
}


struct SlidingTabLeaderboardsView : View {
    @EnvironmentObject var leaderboards: Leaderboards
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack() {
            // The names of the tabs.
            SlidingTabView(selectionState: self.$selectedTabIndex, selection: self.$selectedTabIndex, tabs: ["WEEKLY", "MONTHLY", "YEARLY"], font: Font.callout, activeAccentColor: Color(.label), inactiveAccentColor: Color(.secondaryLabel), selectionBarColor: Color(.label) )
            
            if !leaderboards.leaderboards.isEmpty{
                if selectedTabIndex == 0 {
                    LeaderboardsView(leaderboardInd: 0)
                        .environmentObject(leaderboards)
                } else if selectedTabIndex == 1{
                    LeaderboardsView(leaderboardInd: 1)
                        .environmentObject(leaderboards)
                } else if selectedTabIndex == 2{
                    LeaderboardsView(leaderboardInd: 2)
                        .environmentObject(leaderboards)
                }
            }
            else {
                List{
                    HStack(alignment: .center){
                        ActivityIndicator()
                    }.frame(width: screenWidth)
                }
            }
        }
        .animation(.default)
    }
}
