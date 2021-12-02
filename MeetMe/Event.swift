//
//  Event.swift
//  MeetMe
//
//  Created by Pamela Vazquez De La Cruz on 10/17/21.
//

import Foundation

class Event{
    
    var eventName: String
    var eventDate: String
    var startTime: String
    var endTime: String
    var location: String
    var notifications: Bool
    var reminderTime: String
    var polls: Bool
    var messages: Bool
    var editEvents: Bool
    var eventCreator: String
    var nameOfGroup: String
    var listOfAttendees:[String] = []
    var eventHash: String
    var groupHash: String
    
    init(eventName: String, eventDate: String, startTime: String, endTime: String, location: String, notifications: Bool, reminderChoice: String, polls: Bool, messages: Bool, editEvents: Bool, eventCreator: String, nameOfGroup: String, listOfAttendees: [String], eventHash: String, groupHash: String){
        
        self.eventName = eventName
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.notifications = notifications
        self.reminderTime = reminderChoice
        self.polls = polls
        self.messages = messages
        self.editEvents = editEvents
        self.eventCreator = eventCreator
        self.nameOfGroup = nameOfGroup
        self.listOfAttendees = listOfAttendees
        self.eventHash = eventHash
        self.groupHash = groupHash
    }
    
    func printEventDetails()-> String{
        let cellEventDetails = " \(startTime) : \(eventName) @ \(location)"
        return cellEventDetails
    }
    
    
}
