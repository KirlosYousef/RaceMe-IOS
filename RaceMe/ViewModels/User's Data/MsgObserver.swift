//
//  MsgObserver.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 15..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import Firebase

/**
 Responsible for receiving and sending the chats data from and to Firestore.
 
 - Precondition: chatId is required and should not be empty, and should contain the first and second user ids only!
 */
class MsgObserver : ObservableObject{
    
    @Published var msgs = [msgType]()
    var chatId = ""
    var chatOwner = ""
    var newMsgs = false
    let db = Firestore.firestore()
    var receiver = ""
    
    init(chatIds: [String]) {
        // Here we will seperate the received ids.
        self.chatId = chatIds[0] // Sorted chatId
        let firstUser = chatIds[1] // First user Id
        let secondUser = chatIds[2] // Second user Id
        receiver = (currentUserID == firstUser ? secondUser : firstUser)
        
        let chatRef = db.collection("users").document(firstUser).collection("chats").document(self.chatId)
        
        // Check if the chat is exist on the first user's documents
        chatRef.getDocument { (document, err) in
            if err == nil {
                if let document = document{
                    if document.exists{
                        // If the chat exists set the chatOwner to be the profile id of this user
                        self.chatOwner = firstUser
                    } else {
                        // If not, then set the chatOwner to the other user.
                        // In this case if the second user has the chat we will get the messages directly, and if not, it will create a new chat this second user will be the chat owner
                        self.chatOwner = secondUser
                    }
                    self.getMsgs()
                }
            } else {
                print((err?.localizedDescription)!)
            }
        }
        
    }
    
    /**
     Gets the chats from Firestore and adds it to the msgs list.
     
     - precondition: 'chatOwner' must not me empty.
     */
    func getMsgs(){
        let msgsRef = db.collection("users").document(self.chatOwner).collection("chats").document(self.chatId).collection("msgs").order(by: "time").limit(toLast: 15) // Order messeges by "time" field, which is being sent by each msg, and limit them by only the last 50 msgs.
        
        msgsRef.addSnapshotListener { (snap, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documentChanges{
                if i.type == .added{ // If a new msg added.
                    
                    let id = i.document.documentID
                    
                    if let sender = i.document.get("sender") as? String{
                        
                        let msg = i.document.get("msg") as! String
                        
                        var seen = true
                        
                        if sender != currentUserName{
                            if i.document.get("seen") != nil{
                                seen = i.document.get("seen") as! Bool
                            }
                            if seen == false {self.newMsgs = true}
                        }
                        
                        let time = i.document.get("time") as! Timestamp
                        
                        // Get all messages of the chat and add them to the msgs list, so we can list them on the scrollview.
                        self.msgs.append(msgType(id: id, sender: sender, msg: msg, time: time, seen: seen))
                    }
                }
            }
        }
    }
    
    /**
     This function will be called to add a new message in the chat.
     
     - Parameters:
     - msg: The message to be send.
     - sender: The sender of the message.
     */
    func addMsg(msg: String, sender: String){
        let db = Firestore.firestore()
        db.collection("users").document(self.chatOwner).collection("chats").document(chatId).collection("msgs").addDocument(data: [
            "sender" : sender,
            "msg" : msg,
            "time" : Timestamp(date: Date()),
            "seen" : false
        ]) { (err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            //            print("Success")
            PushNotificationManager.shared.sendNotification(to: self.receiver, title: sender, body: msg, type: NotificationType.Message)
        }
    }
    
    
    
    
    ///This function will be called to update the seen status of a message in the chat.
    func updateSeen(){
        let db = Firestore.firestore()
        db.collection("users").document(self.chatOwner).collection("chats").document(chatId).collection("msgs").whereField("seen", isEqualTo: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if document.get("sender") as! String != currentUserName{
                            document.reference.updateData(["seen": true])
                            print("\(document.documentID) => \(document.data())")
                        }
                    }
                }
        }
    }
}
