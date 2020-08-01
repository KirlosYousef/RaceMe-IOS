//
//  FriendView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 09..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct FriendView: View {
    
    @State var friendInd : Int
    @EnvironmentObject var friends : Friends
    @ObservedObject var msgObserver : MsgObserver
    @ObservedObject var chatObserver : ChatObservers
    @Binding var allChatObservers : [ChatObservers]
    
    var body: some View {
        HStack{
            KFImageView(picURL: chatObserver.friend.picture, imageWidth: screenWidth / 7, imageHeight: screenWidth / 7)
            // When selecting a friend, go to this friend's chat
            NavigationLink(destination: MsgsView(msg: msgObserver, allChatObservers: $allChatObservers,chatName: chatObserver.friend.name, otherUserId: chatObserver.friend.profileId, profPic: chatObserver.friend.picture
            ).environmentObject(self.friends)
            ) {
                HStack{
                    // Friend's state is online or not
                    //                    if friends.friends.count ==
                    //                        self.friends.friendsOnlineStatus.count{
                    //                        if self.friends.friendsOnlineStatus[friendInd] == true{
                    //
                    //                            OnlineState(isOnline: true)
                    //                        } else {OnlineState(isOnline: false)}
                    //                    } else {OnlineState(isOnline: false)}
                    
                    // Friend's name
                    VStack(alignment: .leading){
                        
                        Text(chatObserver.friend.name)
                            .foregroundColor(Color(.label))
                        
                        if msgObserver.msgs.last?.msg != nil{
                            HStack{
                                if msgObserver.msgs.last?.sender == currentUserName{
                                    Text("You:")
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                Text(msgObserver.msgs.last!.msg)
                                    .foregroundColor(msgObserver.newMsgs ? Color(.label) : Color(.secondaryLabel))
                                    .fontWeight(msgObserver.newMsgs ? .bold : .regular)
                            }
                            
                        }
                    }
                    Spacer()
                    if msgObserver.newMsgs{
                        NewMsgIndicator()
                    }
                }
            }
        }.padding()
    }
}

struct OnlineState: View {
    @State var isOnline : Bool
    var body: some View {
        Group{
            if isOnline{
                Color(.systemGreen).frame(width: 10, height: 10)
                    .clipShape(Circle())
                    .offset(x: -20, y: -20)
            } else{
                Color(.systemGray).frame(width: 10, height: 10)
                    .clipShape(Circle()).offset(x: -20, y: 20)
            }
        }
    }
}

struct NewMsgIndicator : View{
    var body: some View{
        Color(.systemBlue).frame(width: 20, height: 20)
            .clipShape(Circle())
    }
}
