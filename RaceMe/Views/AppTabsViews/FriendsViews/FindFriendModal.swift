//
//  FindFriendModal.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 09..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct FindFriendModal : View{
    
    @State private var showCancelButton: Bool = false
    @EnvironmentObject var friends : Friends
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack{
            TextField("Enter a Player's name", text: self.$friends.userName, onEditingChanged: { isEditing in
                self.showCancelButton = isEditing
            }, onCommit: {
                self.showCancelButton.toggle()
                self.friends.findUser()
            })
                .modifier(TextFieldModifier(text: self.$friends.userName, visible: self.$showCancelButton))
                .resignKeyboardOnDragGesture()
                .padding(.top, 20)
            
            List{
                if self.friends.hasResult{
                    ForEach(0..<self.friends.resultUsers.count, id:\.self){ userInd in
                        HStack{
                            // The profile picture of the resulted user
                            KFImageView(picURL: self.friends.resultUsers[userInd].picture, imageWidth: screenWidth / 7, imageHeight: screenWidth / 7)
                            
                            // User's name
                            Text(self.friends.resultUsers[userInd].name)
                                .foregroundColor(Color(.label))
                            
                            Spacer()
                            
                            // Add friend button
                            // If the user is not a friend or same current user then show the add friend button!
                            if (!self.friends.friends
                                .contains(where: { $0.profileId == self.friends.resultUsers[userInd].profileId }))
                                && (currentUserID != self.friends.resultUsers[userInd].profileId)
                            {
                                Button(action: {self.friends.addFriend(profileIndex: userInd)
                                    self.presentationMode.wrappedValue.dismiss() // Dismiss the modal
                                }) {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(darkBackground)
                                        .font(Font.callout)
                                }
                            }
                        }.padding()
                    }
                }
                else{
                    Text("NO PLAYERS FOUND!")
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct FindFriendModal_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            FindFriendModal().environmentObject(Friends())
            FindFriendModal().environmentObject(Friends())
                .environment(\.colorScheme, .dark)
        }
    }
}

