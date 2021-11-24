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
    
    var members: [String] = [] //add creator to list
    var events: [String] = []
    var inviteLink: String = String()
    var groupPicture: String = ""
    
    init(){
        groupHASH = String()
        groupName = String()
        groupDescr = String()
        adminRun = false
        groupCreator = String()
        
        members = [] //add creator to list
        events = []
        inviteLink = String()
        groupPicture = String()
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
