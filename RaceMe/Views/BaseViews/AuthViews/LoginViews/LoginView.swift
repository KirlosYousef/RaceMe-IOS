//
//  LoginView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @State var value: CGFloat = 0
    @State var forgotPasswordShowing: Bool = false
    @State var loginViewisShowingBack: Bool = false
    @EnvironmentObject var login: Login
    
    var body: some View{
        VStack{
            if self.forgotPasswordShowing && !loginViewisShowingBack {
                ForgotPasswordView(loginViewShowing: $loginViewisShowingBack)
                    .environmentObject(login)
            } else{
                VStack(alignment: .leading){
                    
                    Text("Welcome back")
                        .font(.largeTitle)
                        .foregroundColor(.darkColor)
                        .padding()
                        .offset(y: -self.value)
                    
                    Text("Please provide your data to access your account.")
                        .font(.title)
                        .foregroundColor(Color(.secondaryLabel))
                        .padding()
                        .offset(y: -self.value)
                    
                    VStack(alignment: .center){
                        
                        Spacer()
                        
                        CustomTextField(placeholder: "Email", textHolder: self.$login.userLoginData.email)
                        
                        CustomTextField(placeholder: "Password", isSecured: true, textHolder: self.$login.userLoginData.password)
                        
                        
                        Text(self.login.loginFeedback)
                            .foregroundColor(Color(.systemRed))
                        
                        Spacer()
                        
                        Button(action: {
                            self.login.login()
                        }) {
                            Text("Login")
                                .modifier(ButtonModifier())
                        }.padding()
                        
                        
                        Button(action: {
                            self.forgotPasswordShowing = true
                        }) {
                            HStack{
                                Text("Forgot your password?")
                                Text("Click here")
                                    .fontWeight(.bold)
                            }
                        }.padding(.bottom, 50)
                        
                        Spacer()
                        
                    }
                }
            }
        }
        .modifier(OnTextFieldAppearedModifier(value: self.$value, heightController: 1.5))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            LoginView()
                .environmentObject(Login())
            
            LoginView()
                .environmentObject(Login())
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
        }
    }
}
