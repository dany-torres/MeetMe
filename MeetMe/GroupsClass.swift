//
//  GroupsClass.swift
//  MeetMe
//
//  Created by Alejandro Balderas Knoell on 10/18/21.
//

import Foundation

class Group{
    var adminRun: Bool = true
    var groupName: String = ""
    var groupDescr: String = ""
    var members: [User] = [] //add creator to list
    var inviteLink: String = ""
//    let admin: User = User() //set to be the current user
    var groupPicture: String = ""
    
    var events: [String] = []
    
    init(){
    }
    
    //SETTING ADMIN
    func setAdminRun(setting: Bool) {
        adminRun = setting
    }
    
    //NAME
    func changeName(newName: String){
        if !adminRun{
            groupName = newName
        }
    }
     //INVITE LINK
    func createInviteLink()->String{
        inviteLink = "Test_invite_link"
        return inviteLink
    }
    
    //PICTURE
    func changeGroupPicture(){
        
    }
    
    //DESCRIPTION
    func changeDescription(newName: String){
        if !adminRun{
            groupName = newName
        }
    }
    
    //ADDING EVENT
    func addEvent(newEvent: String){
        if !adminRun{
            events.append(newEvent)
        }
    }
    
}
