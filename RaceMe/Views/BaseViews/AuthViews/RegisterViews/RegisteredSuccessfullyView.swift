//
//  RegisteredSuccessfullyView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct ProcessSuccessfullyDoneView: View {
    
    @Binding var loginViewShowing: Bool
    @State var msg: String = "Thank you for joining us!"
    
    var body: some View{
        VStack{
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(.systemBlue))
            
            Text(msg)
                .font(.largeTitle)
                .foregroundColor(.darkColor)
                .padding()
            
            
            VStack(alignment: .leading){
                Text("To complete the process, please click the link in the email we just sent you.")
                
                
                Text("If it doesn’t show up in a few minutes, check your spam folder.")
                    .padding(.top)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .font(.subheadline)
            .padding()
            Spacer()
            
            Button(action: {
                self.loginViewShowing = true
            }, label: {
                Text("Login")
                    .modifier(ButtonModifier())
            })
            Spacer()
        }
    }
}

struct RegisteredSuccessfullyView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ProcessSuccessfullyDoneView(loginViewShowing: .constant(false))
            ProcessSuccessfullyDoneView(loginViewShowing: .constant(false))
            .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
            
        }
    }
}
