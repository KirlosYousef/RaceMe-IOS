//
//  RegisterView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct RegisterView: View {
    
    @State var value: CGFloat = 0
    @Binding var loginViewShowing: Bool 
    @EnvironmentObject var register: Register
    
    var body: some View{
        VStack(alignment: .leading){
            
            Text("Welcome")
                .font(.largeTitle)
                .foregroundColor(.darkColor)
                .padding()
                .offset(y: -self.value)
            
            Text("Please provide your data to create a new account.")
                .font(.title)
                .foregroundColor(Color(.secondaryLabel))
                .padding()
                .offset(y: -self.value)
            
            VStack(alignment: .center){
                
                Spacer()
                
                CustomTextField(placeholder: "Email", textHolder: self.$register.userAuthData.email)
                
                CustomTextField(placeholder: "Password", isSecured: true, textHolder: self.$register.userAuthData.password)
                
                
                Text(self.register.registerFeedback)
                    .foregroundColor(Color(.systemRed))
                
                Spacer()
                
                Button(action: {
                    self.register.register()
                }) {
                    Text("Create an Account")
                        .modifier(ButtonModifier())
                }.padding()
                
                
                Button(action: {
                    self.loginViewShowing = true
                }) {
                    HStack{
                        Text("Already have an account?")
                        Text("Log In")
                            .fontWeight(.bold)
                    }
                    .modifier(ButtonModifier())
                }.padding(.bottom, 50)
                
                Spacer()
                
                HStack{
                    VStack {
                        Text("By creating an account. I agree to RaceMe's")
                        HStack(spacing: 0) {
                            Button("privacy policy") {
                                let url = URL.init(string: "https://www.raceme.tech/privacy_policy.html")
                                guard let privacyPolicy = url, UIApplication.shared.canOpenURL(privacyPolicy) else { return }
                                UIApplication.shared.open(privacyPolicy)
                            }
                            Text(" and ")
                            Button("terms of service") {
                                let url = URL.init(string: "https://www.raceme.tech/terms_and_conditions.html")
                                guard let termsAndConditions = url, UIApplication.shared.canOpenURL(termsAndConditions) else { return }
                                UIApplication.shared.open(termsAndConditions)
                            }
                            Text(".")
                        }
                    }.font(.subheadline)
                        .padding()
                }
            }
        }.background(Color(.systemBackground))
            .modifier(OnTextFieldAppearedModifier(value: self.$value, heightController: 1.5))
    }
}


struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            RegisterView(loginViewShowing: .constant(false))
                .environmentObject(Register())
            
            RegisterView(loginViewShowing: .constant(false))
                .environmentObject(Register())
                .environment(\.colorScheme, .dark)
        }
    }
}

