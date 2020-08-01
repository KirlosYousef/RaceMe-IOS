//
//  Analytics.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 06. 05..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import Analytics


/// Sends all the analytics data.
class Analytics{
    
    static let shared = Analytics()
    
    func setup(){
        let configuration = SEGAnalyticsConfiguration(writeKey: "Segment Analytics Key") // TO FILL
        
        configuration.trackApplicationLifecycleEvents = true // Enable this to record certain application events automatically!
        
        SEGAnalytics.setup(with: configuration)
    }
    
    func screen(_ screenName: String){
        SEGAnalytics.shared()?.screen(screenName)
    }
    
    func identify(_ userId: String, traits: [String: Any]){
        SEGAnalytics.shared()?.identify(userId, traits: traits)
    }
    
    func track(_ event: String, properties: [String: Any]){
        SEGAnalytics.shared()?.track(event, properties: properties)
    }
    
}
