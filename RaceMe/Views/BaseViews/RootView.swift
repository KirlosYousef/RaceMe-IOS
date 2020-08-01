//
//  RootView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 18..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct RootView: View{
    
    @EnvironmentObject var login : Login
    @EnvironmentObject var register : Register
    @EnvironmentObject var matchmaking : Matchmaking
    
    var body: some View {
        VStack{
            if login.isNewUser{
                ProfileDataInsertView()
                    .environmentObject(login)
            } else if (login.isLoggedIn){ // if the user is logged in.
                AppTabsView()
                    .environmentObject(login)
                    .environmentObject(register)
                    .environmentObject(matchmaking)
            } else { // Otherwise show the login view.
                AuthView()
                    .environmentObject(login)
                    .environmentObject(register)
            }
        }
        //        .edgesIgnoringSafeArea(.top)
    }
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(Login())
            .environmentObject(Register())
            .environmentObject(Matchmaking())
    }
}
