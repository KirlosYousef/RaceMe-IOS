//
//  MatchObserver.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 15..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import Firebase
import Analytics

/**
 Responsible for receiving and sending the match data from and to Firestore.
 
 - Precondition: matchId is required and should not be empty, and should contain the first and second user ids only!
 */
class ProgressObserver : ObservableObject{
    
    @Published var progressData = progressType(firstRunnerProgress: 0, secondRunnerProgress: 0)
    @Published var isMatchEnded: Bool = false
    @Published var winner: String = ""
    
    private let db = Firestore.firestore()
    private var matchStarted = false
    private var matchId = ""
    
    var firstRunnerId = ""
    var secondRunnerId = ""
    var firstRPic = defaultProfPic
    var secondRPic = defaultProfPic
    
    // BOT DATA
    private var BOTDistance = 0.0
    private var BOTRunnedPercentage = 0
    private var BOTSpeed: Double = Double.random(in: 1.6 ..< 3.3) // Meter Per Second
    private var chosenDistance: Double = 1000
    
    
    init(matchId: [String], profPicsForID: [String: String], chosenDistance: Double) {
        self.chosenDistance = chosenDistance
        
        // Here we will sort the received ids.
        let sortedMatchId = matchId.sorted()
        firstRunnerId = sortedMatchId[0]
        secondRunnerId = sortedMatchId[1]
        
        // Set the pictures according to the runners order from the dictionary
        firstRPic = profPicsForID[firstRunnerId] ?? defaultProfPic
        secondRPic = profPicsForID[secondRunnerId] ?? defaultProfPic
        
        // Generate a sorted matchId of the firstRunner id and secondRunner id, which will be unique and easy to get back.
        self.matchId = firstRunnerId + secondRunnerId
        
        let matchRef = db.collection("matches").document(self.matchId)
        
        
        matchRef.getDocument { (document, err) in
            if err == nil {
                if let _ = document{
                    self.getprogressData()
                }
            } else {
                print((err?.localizedDescription)!)
            }
        }
        
        let properties = ["Chosen Distance" : chosenDistance]
        Analytics.shared.track("Started Match", properties: properties)
    }
    
    ///Gets the match progress from Firestore and set it to the progressData.
    func getprogressData(){
        if !isMatchEnded{
            var firstRunnerData: CGFloat = 0
            var secondRunnerData: CGFloat = 0
            
            let progressDataRef = db.collection("matches").document(self.matchId).collection("matchData")
                .document("match")
            
            // Listen to the changes of the document!
            progressDataRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    // called when the match start and when the match ends if the app was suspended
                    if !self.matchStarted{
                        //                        print("Match just started!")
                        self.matchStarted = true
                    } else {
                        //                        print("Match might be ended while the app was suspended!.")
                        self.winner = firstRunnerData >= secondRunnerData ? self.firstRunnerId : self.secondRunnerId
                        
                        self.isMatchEnded = true
                    }
                    
                    return
                }
                
                if let currentFirstRunnerData = data[self.firstRunnerId] as? CGFloat{ // First runner progress
                    firstRunnerData = currentFirstRunnerData
                    // If it's 100 or more, make sure it's not more than 100! and then  delete the document.
                    if (currentFirstRunnerData >= 100){
                        firstRunnerData = 100
                        self.winner = self.firstRunnerId
                        self.isMatchEnded = true
                        progressDataRef.delete()
                        // END MATCH
                    }
                }
                if let currentSecondRunnerData = data[self.secondRunnerId] as? CGFloat{ // Second runner progress
                    secondRunnerData = currentSecondRunnerData
                    if (currentSecondRunnerData >= 100){
                        secondRunnerData = 100
                        self.winner = self.secondRunnerId
                        self.isMatchEnded = true
                        progressDataRef.delete()
                        // END MATCH
                    }
                }
                
                // Set the current data to the progessData
                self.progressData = progressType(firstRunnerProgress: firstRunnerData, secondRunnerProgress: secondRunnerData)
            }
        }
    }
    
    /**
     This function will be called to update the progress in the match.
     
     - Parameters:
     - progress: The progress amount to be sent.
     */
    func addprogress(progress: CGFloat){
        let db = Firestore.firestore()
        
        func updateBOT(){
            self.BOTDistance = self.BOTDistance + self.BOTSpeed
            self.BOTRunnedPercentage = Int((self.BOTDistance / self.chosenDistance) * 100)
        }
        
        db.collection("matches").document(matchId).collection("matchData").document("match").getDocument(completion: { (doc, err) in
            if err == nil{
                if let doc = doc{
                    if doc.exists{
                        doc.reference.updateData([
                            currentUserID : progress
                        ])
                        
                        // If one of the runners is a bot, update its data.
                        if self.firstRunnerId == "BOT"{
                            updateBOT()
                            doc.reference.updateData([
                                self.firstRunnerId : CGFloat(self.BOTRunnedPercentage)
                            ])
                        } else if self.secondRunnerId == "BOT"{
                            updateBOT()
                            doc.reference.updateData([
                                self.secondRunnerId : CGFloat(self.BOTRunnedPercentage)
                            ])
                        }
                        //                        print("UPDATED!")
                    }
                    else{
                        if !self.isMatchEnded{
                            doc.reference.setData([
                                self.firstRunnerId : 0,
                                self.secondRunnerId : 0
                            ])
                            //                            print("CREATED!")
                        }
                    }
                    
                }
            }
        })
    }
    
    
    /// This function will be called when the player choose to surrender and will mark the other player as the winner by updating his score to 100.
    func surrender(){
        let db = Firestore.firestore()
        
        let winnerId = (firstRunnerId == currentUserID ? secondRunnerId : firstRunnerId)
        let losserId = currentUserID
        db.collection("matches").document(matchId).collection("matchData").document("match").getDocument(completion: { (doc, err) in
            if err == nil{
                if let doc = doc{
                    if doc.exists{
                        doc.reference.updateData([
                            winnerId : 100,
                            losserId : 0
                        ])
                    } else {
                        doc.reference.setData([
                            winnerId : 100,
                            losserId : 0
                        ])
                    }
                    
                }
            }
        })
    }
}
