//
//  ContentView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 14..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//


import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var login: Login
    @EnvironmentObject var register: Register
    
    var body: some View {
        NavigationView{
            VStack{
                VStack(alignment: .leading){
                    Text("RACE ME!")
                        .font(.system(size: 65))
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemBackground))
                        .padding(.top, OneThirdScreenHeight / 5)
                    
                    Text("Challenge, Run, Win and Make New Friends.")
                        .font(.largeTitle)
                        .foregroundColor(Color(.systemBackground))
                }
                
                Spacer()
                
                AuthButtons()
                
            }.background(
                ZStack{
                    Image("RunningImage")
                        .resizable()
                        .scaledToFill()
                    Color(.tertiaryLabel).opacity(0.2)
                }
            )
                .edgesIgnoringSafeArea(.all)
                .animation(.default)
        }
    }
}


struct AuthButtons: View {
    
    @State var emailAuthViewShowing: Bool = false
    @EnvironmentObject var register: Register
    @EnvironmentObject var login: Login
    
    var body: some View {
        VStack{
            
            FbLoginButtonView(isLoggedIn: $login.isLoggedIn)
            .frame(width: screenWidth / 1.3, height: 50)
            
            SignInWithAppleView().environmentObject(login)
            .frame(width: screenWidth / 1.3, height: 50)
            
            NavigationLink(destination: EmailAuthView()
                .environmentObject(register)
                .environmentObject(login),
                           isActive: self.$emailAuthViewShowing) {
                            
                            Button(action: {
                                self.emailAuthViewShowing = true
                            }) {
                                Text("Continue with Email")
                                    .modifier(ButtonModifier())
                            }.padding(.bottom, 50)
            }
        }
    }
}


struct ButtonModifier: ViewModifier {
    
    @State var bgColor = Color(.secondarySystemBackground)
    @State var txtColor = Color(.label)
    
    func body(content: Content) -> some View {
        ZStack{
            content
                .foregroundColor(txtColor)
                .frame(width: screenWidth / 1.3, height: 50)
                .background(bgColor)
                .cornerRadius(5.0)
        }
    }
}


extension Color {
    static let darkColor = Color("DarkColor")
    static let lightColor = Color("LightColor")
}


struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            AuthView()
                .environmentObject(Login())
                .environmentObject(Register())
            AuthView()
                .environmentObject(Login())
                .environmentObject(Register())
                .environment(\.colorScheme, .dark)
        }
    }
}
