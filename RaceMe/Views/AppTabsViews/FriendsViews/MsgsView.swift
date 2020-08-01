//
//  ChatView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 15..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import Firebase


/**
 The view of the chats with other users.
 
 - Remark: 'msgObserver' is required!
 */
struct MsgsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var friends : Friends
    @ObservedObject var msg : MsgObserver
    
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .remove
    
    @State private var didPressMail = false
    @State private var canSendMail = true
    
    @State private var showOptionsSheet = false
    
    @State var value : CGFloat = 0
    @State var typedMsg = ""
    @Binding var allChatObservers : [ChatObservers]
    var chatName = ""
    var otherUserId = ""
    var profPic = ""
    
    var body: some View {
        
        VStack{
            CustomScrollView(scrollToEnd: true){
                ForEach(self.msg.msgs){msg in
                    if msg.sender == currentUserName{
                        MsgRow(msg: msg.msg, isMyMsg: true, sender: msg.sender, profPic: self.profPic)
                            .padding(6)
                    } else {
                        MsgRow(msg: msg.msg, isMyMsg: false, sender: msg.sender, profPic: self.profPic)
                            .padding(6)
                    }
                }
                .padding(.top, 10)
            }.onAppear {
                if self.msg.newMsgs{
                    self.msg.updateSeen()
                }
                self.msg.newMsgs = false
            }
            HStack{
                TextField("Message", text: $typedMsg)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if self.typedMsg != ""{
                        self.msg.addMsg(msg: self.typedMsg, sender: currentUserName)
                        self.typedMsg = ""
                    }
                }) {
                    Text("Send")
                }
            }.padding()
            
        }
        .navigationBarTitle(Text(chatName), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.showOptionsSheet = true
            }, label: {
                Image(systemName: "ellipsis.circle")
                    .font(Font.callout.weight(.light))
                
            })
        )
            .modifier(OnTextFieldAppearedModifier(value: self.$value, heightController: 1.3))
            
            .alert(isPresented: self.$showAlert) { () -> Alert in
                switch activeAlert {
                case .block:
                    return Alert(title: Text("Block User"), message: Text("Are you sure you want to block \(self.chatName), this action cannot be undone!"), primaryButton: .cancel(), secondaryButton: .default(Text("Block"), action: {
                        self.friends.blockUser(self.otherUserId)
                        self.allChatObservers.removeAll { (obs) -> Bool in
                            obs.friend.profileId == self.otherUserId
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }))
                case .remove:
                    return Alert(title: Text("Remove User"), message: Text("Are you sure you want to remove \(self.chatName) from your friends list?"), primaryButton: .cancel(), secondaryButton: .default(Text("Remove"), action: {
                        self.friends.removeFriend(self.otherUserId)
                        self.allChatObservers.removeAll { (obs) -> Bool in
                            obs.friend.profileId == self.otherUserId
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }))
                }
        }
            
        .sheet(isPresented: self.$didPressMail) {
            if self.canSendMail{
                
                ContactViewRepresentable(mailSubject: "Report \(self.chatName): \(self.otherUserId)", mailBody: "Reason: ", canSendMail: self.$canSendMail)
            } else {
                VStack{
                    Text("You don't have mail app setup.")
                    
                    Text("Plese use the following email to reach us:")
                    
                    Text("support@raceme.tech")
                }
            }
        }
            
        .actionSheet(isPresented: $showOptionsSheet) {
            ActionSheet(title: Text("Options"), message: Text("Select one of the following options!"), buttons: [
                .default(Text("Report")) {
                    self.didPressMail = true},
                
                .default(Text("Remove")) {
                    self.activeAlert = .remove
                    self.showAlert = true},
                
                .default(Text("Block")) {
                    self.activeAlert = .block
                    self.showAlert = true },
                .cancel()
            ])
        }
    }
}

struct msgType : Identifiable{
    var id : String
    var sender : String
    var msg : String
    var time : Timestamp
    var seen : Bool
}

/**
 The view of each message in the scroll view.
 
 The view of the message varies according to the message sender.
 */
struct MsgRow : View{
    var msg = ""
    var isMyMsg = false
    var sender = ""
    var profPic = ""
    
    var body : some View{
        ZStack{
            
            // To fix the custom scrolling issue.
            Color(.systemBackground).frame(width: UIScreen.main.bounds.width - 50)
            
            HStack{
                if self.isMyMsg{ // If the sender is the current user.
                    HStack{
                        Spacer()
                        
                        Text(self.msg).padding(8)
                            .background(darkBackground)
                            .cornerRadius(6)
                            .foregroundColor(.white)
                    }
                } else {
                    HStack(){
                        // The profile picture of the other user
                        KFImageView(picURL: self.profPic, imageWidth: 40, imageHeight: 40)
                        
                        Text(self.msg).padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(6)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

enum ActiveAlert {
    case block, remove
}

struct MsgsView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MsgsView(msg: MsgObserver(chatIds: ["SenderReciver", "Sender", "Reciver"]), allChatObservers: .constant([ChatObservers(friend: Friend(profileId: currentUserID, name: currentUserName, picture: defaultProfPic), chatObserver: MsgObserver(chatIds: ["SenderReciver", "Sender", "Reciver"]))]))
            
            MsgsView(msg: MsgObserver(chatIds: ["SenderReciver", "Sender", "Reciver"]), allChatObservers: .constant([ChatObservers(friend: Friend(profileId: currentUserID, name: currentUserName, picture: defaultProfPic), chatObserver: MsgObserver(chatIds: ["SenderReciver", "Sender", "Reciver"]))]))
                .environment(\.colorScheme, .dark)
        }
    }
}
