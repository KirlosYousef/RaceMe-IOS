//
//  ForgotPasswordView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 10..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct ForgotPasswordView : View {
    
    @EnvironmentObject var login: Login
    @Binding var loginViewShowing: Bool
    @State var showClearButton: Bool = false
    @State var requestSubmitted: Bool = false
    @State var showAlert: Bool = false
    @State var value: CGFloat = 0
    
    var body: some View {
        VStack{
            VStack{
                
                Spacer()
                
                Text("Password Reset")
                    .foregroundColor(Color(.label))
                    .font(.title)
                    .padding(.top)
                Spacer()
                
                VStack(alignment: .leading){
                    
                    Text("Please enter your email:")
                        .foregroundColor(Color(.label))
                        .font(.body)
                        .padding(.leading, 20)
                    
                    CustomTextField(placeholder: "Email", textHolder: self.$login.forgotPasswordEmail)
                }
                
                NavigationLink(destination: ProcessSuccessfullyDoneView(loginViewShowing: self.$loginViewShowing, msg: "If you are registered, you will receive an email shortly."), isActive: self.$requestSubmitted) {
                    Text("")
                }
                
                if self.showAlert{
                    Text("Invalid email!")
                        .foregroundColor(Color(.systemRed))
                        .padding()
                }
                
                if self.value == 0 {
                    Spacer()
                }
                
                
                Button(action: {
                    if isValidEmail(self.login.forgotPasswordEmail){
                        self.showAlert = false
                        self.requestSubmitted = true
                        self.login.forgotPassword()
                    } else {
                        self.showAlert = true
                    }
                }, label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(darkBackground)
                        .cornerRadius(5.0)
                })
                    .padding()   
                Spacer()
            }
        }
    }
}


struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ForgotPasswordView(loginViewShowing: .constant(false))
                .environmentObject(Login())
            
            ForgotPasswordView(loginViewShowing: .constant(false))
                .environmentObject(Login())
                .environment(\.colorScheme, .dark)
        }
    }
}
