//
//  UserDefaults.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 01..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    // MARK: LoggedIn
    /// Sets the current user status.
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: "isLoggedIn")
        synchronize()
    }
    
    /// Gets the current user status.
    func isLoggedIn() -> Bool {
        return bool(forKey: "isLoggedIn")
    }
    
    // MARK: User's Photo
    /// Sets the current user photo.
    func setUserPhoto(value: String) {
        if value == ""{
            set(defaultProfPic, forKey: "userPhoto")
        } else
        { set(value, forKey: "userPhoto") }
        synchronize()
    }
    
    /// Gets the current user photo.
    func getUserPhoto() -> String {
        return string(forKey: "userPhoto") ?? defaultProfPic
    }
    
    // MARK: User's Name
    /// Sets the current user name.
    func setUserName(value: String) {
        if value == "" {
            set("Runner", forKey: "userName")
        } else
        { set(value, forKey: "userName") }
        synchronize()
    }
    
    /// Gets the current user name.
    func getUserName() -> String {
        return string(forKey: "userName") ?? "Runner"
    }
    
    // MARK: User's ID
    /// Sets the current user ID.
    func setUserId(value: String) {
        if value == "" {
            set("RunnerId", forKey: "userId")
        } else
        { set(value, forKey: "userId") }
        synchronize()
    }
    
    /// Gets the current user ID.
    func getUserId() -> String {
        return string(forKey: "userId") ?? "RunnerId"
    }
    
    // MARK: User's Apple ID
    /// Sets the current user ID.
    func setUserAppleId(value: String) {
        set(value, forKey: "userAppleId")
        synchronize()
    }
    
    /// Gets the current user ID.
    func getUserAppleId() -> String {
        return string(forKey: "userAppleId") ?? ""
    }
    
    // MARK: User's Settings
    /// Sets the current user distance unit.
    func setDistanceUnit(unit: String) {
        if unit == ""{
            set("Miles", forKey: "DistanceUnit")
        } else
        {
            set(unit, forKey: "DistanceUnit")
        }
        synchronize()
    }
    
    /// Gets the current user distance unit.
    func getDistanceUnit() -> String {
        return string(forKey: "DistanceUnit") ?? "Miles"
    }
    
    /// Sets to true when the user has an AdFree option.
    func setIsAdFree(value: Bool) {
        set(value, forKey: "adFree")
        synchronize()
    }
    
    /// Checks if the user has an AdFree option.
    func isAdFree() -> Bool {
        return bool(forKey: "adFree")
    }
    
    // MARK: Friends Data
    /// Sets the current user friends.
    func setfriends(friends: [Friend]){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(friends), forKey:"friends")
        synchronize()
    }
    
    /// Gets the current user friends.
    func getFriends() -> [Friend]{
        if let data = UserDefaults.standard.value(forKey:"friends") as? Data {
            let friends = try? PropertyListDecoder().decode(Array<Friend>.self, from: data)
            return friends!
        }
        return []
    }
    
    /// Sets the current blocked users.
    func setBlockedUsers(ids: [String]){
        UserDefaults.standard.set(ids, forKey:"blockedUsers")
        synchronize()
    }
    
    /// Gets the current blocked users.
    func getBlockedUsers() -> [String]{
        if let data = UserDefaults.standard.value(forKey:"blockedUsers") as? [String]{
            return data
        }
        return []
    }
    
    // MARK: Data
    /// Clears all the data from UserDefaults.
    func removeData(){
        setIsLoggedIn(value: false)
        setUserPhoto(value: "")
        setUserName(value: "")
        setUserId(value: "")
        setUserAppleId(value: "")
        setDistanceUnit(unit: "")
        setIsAdFree(value: false)
        setfriends(friends: [])
        setBlockedUsers(ids: [])
        synchronize()
    }
}
