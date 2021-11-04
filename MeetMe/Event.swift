//
//  Event.swift
//  MeetMe
//
//  Created by Pamela Vazquez De La Cruz on 10/17/21.
//

import Foundation

class Event{

//     Date Day/Month/Day --> currently a string
//     Date StartTime --> currently a string
//     Date EndTime --> currently a string
//     Date Reminder --> StartTime - userinput
//     List Attendees <User>

    
    var eventName: String
    var eventCreator: String
    var nameOfGroup: String
    var eventDate: String
    var startTime: String
    var endTime: String
    var location: String
    var notifications: Bool
    var reminderTime: String
    var polls: Bool
    var messages: Bool
    var editEvents: Bool
    var listOfAttendees:[User] = []
    
    init(eventName: String, eventDate: String, startTime: String, endTime: String, location: String, notifications: Bool, reminderChoice: String, polls: Bool, messages: Bool, editEvents: Bool, eventCreator: String, nameOfGroup: String, listOfAttendees: [User]){
        
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
    }
    
    func printEventDetails()-> String{
        let cellEventDetails = " \(startTime) : \(eventName) @ \(location)"
        return cellEventDetails
    }
    
    
}
