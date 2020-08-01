//
//  AppleLoginView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 19..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginView: View {
    
    var body: some View {
        SignInWithAppleView()
            .frame(width: 200, height: 50)
    }
}

struct SignInWithAppleView: UIViewRepresentable {
    
    @EnvironmentObject var login: Login
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black)
        
        button.addTarget(context.coordinator, action:  #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ObservableObject {
        
        let parent: SignInWithAppleView?
        
        init(_ parent: SignInWithAppleView) {
            self.parent = parent
            super.init()
            
        }
        
        @objc func didTapButton() {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.presentationContextProvider = self
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            let vc = UIApplication.shared.windows.last?.rootViewController
            return (vc?.view.window!)!
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("Credentials not found....")
                return
            }
            
            let idToken = String(data: credentials.identityToken!, encoding: .utf8)!
            
            let appleUserID = credentials.user
            
            UserDefaults.standard.setUserAppleId(value: credentials.user)
            
            parent!.login.loginApple(appleUserID: appleUserID, idToken: idToken)
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        }
    }
    
}

struct AppleLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AppleLoginView()
    }
}
