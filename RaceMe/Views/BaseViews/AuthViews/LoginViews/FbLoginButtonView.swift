//
//  LoginButtons.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 10..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit

struct FbLoginButtonView: UIViewRepresentable { // Representable SwiftUI view for Facebook login button.
    
    let loginButton = FBLoginButton()
    @Binding var isLoggedIn : Bool
    
    func makeUIView(context: UIViewRepresentableContext<FbLoginButtonView>) -> FBLoginButton {
        let button = FBLoginButton()
        // The required permissions from the facebook user.
        button.permissions = ["public_profile", "email", "user_friends"]
        button.center = CGPoint(x: UIScreen.main.bounds.width / 2 , y: UIScreen.main.bounds.height / 100)
        button.delegate = context.coordinator
        
        return button
    }
    
    func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<FbLoginButtonView> ) {
    }
    
    func makeCoordinator() -> FbLoginButtonView.Coordinator {
        Coordinator(self, isLoggedIn: $isLoggedIn)
    }
    
    class Coordinator: NSObject, LoginButtonDelegate, ObservableObject {
        
        var fbLoginButton: FbLoginButtonView
        @ObservedObject var login = Login()
        @Binding var isLoggedIn : Bool
        
        
        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            if ((error) != nil) {
                // Process error
                print((error?.localizedDescription)!)
                return
            }
            else if result?.token != nil{
                // Preform the authentication stuff.
                login.loginFacebook()
                isLoggedIn = true
            }
        }
        
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            isLoggedIn = false
            AppDelegate._bc.storedProfileId = ""
            UserDefaults.standard.setIsLoggedIn(value: false)
        }
        
        init(_ fbLoginButton: FbLoginButtonView, isLoggedIn : Binding<Bool>) {
            self.fbLoginButton = fbLoginButton
            self._isLoggedIn = isLoggedIn
        }
    }
}
