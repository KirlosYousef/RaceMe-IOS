//
//  UpdateProfileData.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 10. 27..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation

/**
 This class is responsible for changing and updating the user's data, such as the userName.
 */
class UpdateUserData{
    
    /// Will try to update the user's username in the server.
    func updateUserName(userName: String){
        AppDelegate._bc.playerStateService.updateName(userName,
                                                      completionBlock: nil,
                                                      errorCompletionBlock: nil,
                                                      cbObject: nil)
    }
    
    /// Will try to update the user's picture in the server.
    func updateUserPicture(pictureUrl: String){
        AppDelegate._bc.playerStateService.updateUserPictureUrl(pictureUrl,
                                                                completionBlock: nil,
                                                                errorCompletionBlock: nil,
                                                                cbObject: nil)
        UserDefaults.standard.setUserPhoto(value: pictureUrl)
    }
}
