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
    
    init(eventName: String, eventDate: String, startTime: String, endTime: String, location: String, notifications: Bool, reminderChoice: String, polls: Bool, messages: Bool, editEvents: Bool){
        
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
    }
    
    func printEventDetails()-> String{
        let cellEventDetails = " \(startTime) : \(eventName) @ \(location)"
        return cellEventDetails
    }
    
    func getStartTime() -> String {
        return startTime
    }
    
    func getEndTime() -> String {
        return endTime
    }
    
}
