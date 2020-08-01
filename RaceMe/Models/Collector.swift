//
//  Collector.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 02. 20..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

// MARK: Colors
let lightGreyColor = Color(UIColor.systemGray5)
let darkBackground = Color(UIColor.systemBlue)
let lightBackground = Color(UIColor.secondarySystemBackground)

// MARK: Standards
let OneThirdScreenHeight = UIScreen.main.bounds.height/3
let screenWidth = UIScreen.main.bounds.width

// MARK: Functions
func OpenSansLight(withSize size: Int) -> Font{
    return Font.custom("OpenSans-Light", size: CGFloat(size))
}

// Checks if the entered email is in a valid format or not.
func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

// MARK: Views
struct KFImageView: View {
    
    var picURL: String
    var imageWidth: CGFloat
    var imageHeight: CGFloat
    var lineWidth: CGFloat = 2
    var backgroundColor: Color = Color(.secondarySystemBackground)
    var strokeColor = Color(.secondarySystemBackground)
    
    var body: some View {
        KFImage(URL(string: picURL), options: [.transition(.fade(0.2)),  .keepCurrentImageWhileLoading])
            .placeholder({
                Image(systemName: "arrow.2.circlepath.circle")
                    .font(.largeTitle)
                    .opacity(0.3)
            })
            .resizable()
            .scaledToFill()
            .frame(width: imageWidth, height: imageHeight)
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(Circle().stroke(strokeColor, lineWidth: lineWidth))
    }
}

// MARK: Variables
let changeUserData = UpdateUserData()
let getUserData = GetUserData()
let currentUserName = UserDefaults.standard.getUserName()
let currentUserID = UserDefaults.standard.getUserId()
let defaultProfPic = "https://i.imgur.com/fRfIw8S.png"

