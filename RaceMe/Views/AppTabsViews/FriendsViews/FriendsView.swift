//
//  FriendsView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 03..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import Firebase

// The view of the user's friends.
struct FriendsView: View {
    
    @State private var chatObservers = [ChatObservers]()
    @State private var showModal = false
    @State private var friendsReady: Bool = false
    @EnvironmentObject var friends : Friends
    
    
    // Generate a sorted chatId of the firstUser id and secondUser id, which will be unique and easy to get back.
    private func generateChatIDs(chatUsers: [String]) -> [String]{
        
        let sortedChatId = chatUsers.sorted()
        
        let firstUser = sortedChatId[0]
        
        let secondUser = sortedChatId[1]
        
        let chatID = firstUser + secondUser
        
        return [chatID, firstUser, secondUser]
        
    }
    
    // Updates the chat oberservers, it checks if the observer is already generated or not, if not it will generate a new Observer for this chat.
    func updateObservers(){
        for friendData in self.friends.friends{
            
            let chatUsers = [currentUserID, friendData.profileId]
            
            let chatIds = generateChatIDs(chatUsers: chatUsers)
            
            if !self.chatObservers.contains(where: { (observer) -> Bool in
                
                if observer.chatObserver.chatId == chatIds[0]{
                    return true
                } else{
                    return false
                }
                
            }){
                self.chatObservers.append(ChatObservers(friend: friendData, chatObserver: MsgObserver(chatIds: chatIds)))
            }
        }
        self.sortChats()
        
        self.friendsReady = true
    }
    
    private func sortChats(){
        self.chatObservers.sort { (lhs, rhs) -> Bool in
            let defalut = Timestamp(date: Date(timeIntervalSinceReferenceDate: 0))
            let lhsTime = Timestamp.dateValue(lhs.chatObserver.msgs.last?.time ?? defalut)()
            let rhsTime = Timestamp.dateValue(rhs.chatObserver.msgs.last?.time ?? defalut)()
            return lhsTime > rhsTime
        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                
                // If there is no data about friends yet, Show loading indicator and call listFriends.
                if self.friends.loadingFriends && self.friends.friends.isEmpty {
                    
                    HStack{
                        Spacer()
                        ActivityIndicator()
                        Spacer()
                    }.onAppear {
                        self.friends.listFriends()
                    }
                    
                } else if friends.friends.isEmpty { // If the user has no friends.
                    
                    Spacer()
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: OneThirdScreenHeight / 2))
                        .font(Font.title.weight(.heavy))
                        .foregroundColor(Color(.tertiaryLabel))
                        .padding()
                    
                    Text("It's better with friends, find some!")
                        .font(Font.callout)
                        .foregroundColor(Color(.secondaryLabel))
                    
                    Spacer()
                    
                } else{ // Show the friends list
                    VStack{
                        if self.friendsReady && self.chatObservers.count != 0{
                            // Friends List
                            List{
                                ForEach(0..<self.chatObservers.count, id: \.self){ friendInd in
                                    
                                    FriendView(friendInd: friendInd, msgObserver: self.chatObservers[friendInd].chatObserver, chatObserver: self.chatObservers[friendInd], allChatObservers: self.$chatObservers)
                                        .environmentObject(self.friends)
                                }
                            }
                        }
                    }
                    .onAppear {
                        self.updateObservers()
                    }
                }
            }
            .navigationBarTitle(Text("FRIENDS"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.showModal.toggle()
                }) {
                    Text("Search")
                        .font(Font.callout)
                    
                }.sheet(isPresented: $showModal) {
                    FindFriendModal().environmentObject(self.friends)
                        .onDisappear(perform: {
                            self.friends.listFriends()
                            self.updateObservers()
                        })
                }
                
            )
                .background(Color(.systemBackground))
            //                .onAppear(perform: {
            //                    self.friends.checkFriendsStatus()
            //                })
        }
    }
}


struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            FriendsView().environmentObject(Friends())
            FriendsView().environmentObject(Friends())
                .environment(\.colorScheme, .dark)
        }
    }
}


class ChatObservers: ObservableObject{
    @Published var friend : Friend
    @Published var chatObserver : MsgObserver
    
    init(friend: Friend, chatObserver: MsgObserver) {
        self.friend = friend
        self.chatObserver = chatObserver
    }
}
