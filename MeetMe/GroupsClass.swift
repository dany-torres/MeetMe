//
//  GroupsClass.swift
//  MeetMe
//
//  Created by Alejandro Balderas Knoell on 10/18/21.
//

import Foundation

class Group{
    
    var groupHASH: String = String()
    var groupName: String = String()
    var groupDescr: String = String()
    var adminRun: Bool = Bool()
    var groupCreator: String = String()
    
    var members: [User] = [] //add creator to list
    var events: [Event] = []
    var inviteLink: String = String()
    var groupPicture: String = ""
    
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
    func addEvent(newEvent: Event){
        if !adminRun{
            events.append(newEvent)
        }
    }
    
}
