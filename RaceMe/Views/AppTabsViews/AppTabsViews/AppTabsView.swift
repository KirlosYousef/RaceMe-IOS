//
//  TabView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 31..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import BrainCloud

// This view is to control the tab views and listing them.
struct AppTabsView: View {
    
    @State private var currentTab = 1
    @State private var showingNotificationAlert = false
    @State private var notificationDisabled = false
    @EnvironmentObject var login : Login
    @EnvironmentObject var register : Register
    @EnvironmentObject var matchmaking : Matchmaking
    
    private func checkPushNotification(){
        
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                
                // Notification permission has not been asked yet, go for it!
                self.showingNotificationAlert = true
                
            } else if settings.authorizationStatus == .denied {
                
                // Notification permission was previously denied, go to settings & privacy to re-enable
                self.showingNotificationAlert = true
                self.notificationDisabled = true
                
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
            }
        })
    }
    
    var body: some View {
        VStack{
            if (login.isLoggedIn && matchmaking.matchStarted){
                MatchTabView()
            }
            else if (login.isLoggedIn && !matchmaking.matchStarted){
                TabView(selection: $currentTab){
                    ProfileTabView()
                        .tag(0)
                    
                    StartMatchTabView()
                        .tag(1)
                    
                    FriendsTabView()
                        .tag(2)
                }
                .onAppear {
                    self.checkPushNotification()
                }
                .modifier(AppTabsViewModifier(showingNotificationAlert: self.$showingNotificationAlert, notificationDisabled: self.$notificationDisabled))
            } else {
                RootView()
                    .environmentObject(login)
                    .environmentObject(register)
                    .environmentObject(matchmaking)
            }
        }
    }
}

struct AppTabsViewModifier: ViewModifier {
    
    @Binding var showingNotificationAlert: Bool
    @Binding var notificationDisabled: Bool
    
    private func notificationsDeniedAlert() -> Alert {
        
        let alertTitle = Text("Notifications denied")
        let alertMsg = Text("Notification permission was previously denied, you won't get notified when you reach your goal, to enable go to settings -> Notifications -> RaceMe")
        
        return Alert(title: alertTitle, message: alertMsg, dismissButton: .default(Text("OK")))
    }
    
    private func notificationsRequest() -> Alert {
        
        let alertTitle = Text("Notifications request")
        let alertMsg = Text("Please allow notification access so you get notified when you reach your goal!")
        
        return Alert(title: alertTitle, message: alertMsg, primaryButton: .default(Text("Ok"), action: {
            
            let pushManager = PushNotificationManager.shared
            pushManager.registerForPushNotifications()
            
        }), secondaryButton: .cancel({
            self.showingNotificationAlert = false
        }))
    }
    
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: self.$showingNotificationAlert) { () -> Alert in
                if notificationDisabled{
                    return notificationsDeniedAlert()
                } else {
                    return notificationsRequest()
                }
        }
    }
}


struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            AppTabsView()
                .environmentObject(Login())
                .environmentObject(Register())
                .environmentObject(Matchmaking())
            
            AppTabsView()
                .environmentObject(Login())
                .environmentObject(Register())
                .environmentObject(Matchmaking())
                .environment(\.colorScheme, .dark)
        }
    }
}
