//
//  RegisterView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct EmailAuthView: View {
    
    @EnvironmentObject var register: Register
    @EnvironmentObject var login: Login
    @State var loginViewShowing: Bool = false
    
    var body: some View {
        VStack{
            if self.register.registered{
                ProcessSuccessfullyDoneView(loginViewShowing: self.$loginViewShowing)
            } else {
                RegisterView(loginViewShowing: self.$loginViewShowing)
                    .environmentObject(register)
            }
            NavigationLink(destination: LoginView().environmentObject(login), isActive: self.$loginViewShowing) {
                Text("")
            }
        }
    }
}


struct EmailAuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            EmailAuthView()
                .environmentObject(Register())
            
            EmailAuthView()
                .environmentObject(Register())
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
        }
    }
}
