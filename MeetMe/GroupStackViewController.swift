//
//  GroupStackViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

protocol AddNewEvent {
    func addNewEvent(newEvent: Event)
}

protocol DeleteEvent {
    func deleteEvent(event: Event)
}

protocol UpdateEvent {
    func updateEvent(cell: StackTableViewCell, event:Event)
}

protocol UpdateGroup {
    func updateGroup(group: Group)
}

class GroupStackViewController: UIViewController, UITableViewDataSource,
                                    UITableViewDelegate, AddNewEvent, DeleteEvent,
                                UpdateEvent, UpdateGroup, MyStackCellDelegate {
    
    public var eventList:[Event] = []
    var delegate: UITableView!
    var currGroup: Group!
    var loaded: Bool = false
    
    var halfHours:[String] = []
    var currCell:StackTableViewCell!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var eventStack: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change back button ot go to root rather than create group
        var viewControllersArray = [UIViewController]()
        viewControllersArray.append(self.navigationController!.viewControllers.first!)
        viewControllersArray.append(self.navigationController!.viewControllers.last!)
        self.navigationController?.setViewControllers(viewControllersArray, animated: false)
        
        eventStack.delegate = self
        eventStack.dataSource = self
        
        setDayLabel()
        initTime()
        
        let queue = DispatchQueue(label: "curr")
        queue.async {
            while (!self.loaded){
                sleep(1)
            }
            DispatchQueue.main.async {
                let myNormalAttributedTitle = NSAttributedString(string: self.currGroup.groupName,
                    attributes: [NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: 17)!])
                self.groupNameLabel.setAttributedTitle(myNormalAttributedTitle, for: .normal)
                self.rePopulateEventStack()
            }
//            self.rePopulateEventStack()
        }
    }
    
    // Reload stack to show any event edits
//    override func viewWillAppear(_ animated: Bool) {
//        eventStack.reloadData()
//    }
    
    // Initialize the halfHours array
    func initTime(){
        let possibleHours = ["00", "30"];
        for j in 0...1 {
            if j == 0{
                halfHours.append("12:00 AM");
                halfHours.append("12:30 AM");
            } else {
                halfHours.append("12:00 PM");
                halfHours.append("12:30 PM");
            }
            for i in 1...11 {
                var hourString = String()
                for item in possibleHours{
                    hourString = String(i) + ":" + item
                    if j == 0{
                        halfHours.append(hourString + " AM");
                    } else {
                        halfHours.append(hourString + " PM");
                    }
                }
            }
        }
    }
    
    // Sets the date label to the current day
    func setDayLabel(){
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let month = Calendar.current.component(.month, from: today)
        let year =
        Calendar.current.component(.year, from: today)
        let date = Calendar.current.component(.day, from: today)

        let weekdayText = Calendar.current.shortWeekdaySymbols[weekday-1]
        let monthText = "\(Calendar.current.shortMonthSymbols[month-1]) \(date)"
        
        dateLabel.text = "\(weekdayText) \(monthText), \(year)"
        eventStack.reloadData()
    }
    
    // Set number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return halfHours.count
    }
    
    // Populate cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stackCell", for: indexPath) as! StackTableViewCell
        let row = indexPath.row
        let time = halfHours[row]
        cell.time.text = time
        cell.delegate = self
        let events = getEventsAtCellTime(startTime: time)
        setEvents(cell:cell, events:events)
        return cell
    }
    
    // Check if the first event button was clicked
    func didTapCellButton1(cell:StackTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.eventStack.indexPath(for: cell)
        let cell = eventStack.cellForRow(at: indexPath!) as! StackTableViewCell
        currCell = cell
    }
    
    // Check if the second event button was clicked
    func didTapCellButton2(cell:StackTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.eventStack.indexPath(for: cell)
        let cell = eventStack.cellForRow(at: indexPath!) as! StackTableViewCell
        currCell = cell
    }
    
    // Check if the third event button was clicked
    func didTapCellButton3(cell:StackTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.eventStack.indexPath(for: cell)
        let cell = eventStack.cellForRow(at: indexPath!) as! StackTableViewCell
        currCell = cell
        
        if (currCell != nil && currCell.eventThree.count == 1) {
            self.performSegue(withIdentifier: "singleEvent3", sender: nil)
        } else {
            self.performSegue(withIdentifier: "eventsListSegue", sender: nil)
        }
    }
    
    // Get hour to the nearest half hour
    func getCurrentTime() -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    // Set the events block in the cells accordingly
    func setEvents(cell:StackTableViewCell, events:[Event]) {
        hideUnusedEvents(cell:cell)
//        print(">> GOT IN SET EVENTS, eventsCount: \(events.count)")
        
        switch events.count {
        case 0:
            break
        case 1:
            cell.button1.isHidden = false
            setFirstEventBlock(cell:cell, event:events[0])
        case 2:
            cell.button1.isHidden = false
            cell.button2.isHidden = false
            setFirstEventBlock(cell:cell, event:events[0])
            setSecondEventBlock(cell:cell, event:events[1])
        case 3:
            cell.button1.isHidden = false
            cell.button2.isHidden = false
            cell.button3.isHidden = false
            setFirstEventBlock(cell:cell, event:events[0])
            setSecondEventBlock(cell:cell, event:events[1])
            setThirdEventBlock(cell:cell, event:events[2])
        default:
            cell.button1.isHidden = false
            cell.button2.isHidden = false
            cell.button3.isHidden = false
            if events.count > 3 {
                setFirstEventBlock(cell:cell, event:events[0])
                setSecondEventBlock(cell:cell, event:events[1])
                setMoreThanThreeEvents(cell:cell, extraEvents:Array(events[2...events.count-1]))
            }
            break
        }
    }
    
    // Set the first event block
    func setFirstEventBlock(cell:StackTableViewCell, event:Event){
        cell.event1.isHidden = false
        // Check if not a longer event
        if event.startTime == cell.time.text {
            cell.event1.text = event.eventName
        }
        cell.eventOne = event
        
        cell.event1.backgroundColor = getColor(rgbArray: event.eventColor)
    }
    
    // Set the second event block
    func setSecondEventBlock(cell:StackTableViewCell, event:Event){
        cell.event2.isHidden = false
        if event.startTime == cell.time.text {
            cell.event2.text = event.eventName
        }
        cell.eventTwo = event
        cell.event2.backgroundColor = getColor(rgbArray: event.eventColor)
    }
    
    // Set the third event block
    func setThirdEventBlock(cell:StackTableViewCell, event:Event){
        cell.event3.isHidden = false
        if event.startTime == cell.time.text {
            cell.event3.text = event.eventName
        }
        cell.eventThree = [event]
        cell.event3.backgroundColor = getColor(rgbArray: event.eventColor)
    }
    
    // Set the third event block when there are more events
    func setMoreThanThreeEvents(cell:StackTableViewCell, extraEvents:[Event]){
        cell.event3.isHidden = false
        cell.event3.text = String(extraEvents.count) + " More Events"
        cell.eventThree = extraEvents
    }
    
    // Func to get the color of the event block based on User color
    func getColor(rgbArray:[Int]) -> UIColor {
        let red:CGFloat = CGFloat(rgbArray[0])/CGFloat(255)
        let green:CGFloat = CGFloat(rgbArray[1])/CGFloat(255)
        let blue:CGFloat = CGFloat(rgbArray[2])/CGFloat(255)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    // Hide any event blocks that are not being used
    func hideUnusedEvents(cell:StackTableViewCell) {
        cell.event1.isHidden = true
        cell.event2.isHidden = true
        cell.event3.isHidden = true
    }
    
    // Get all events that happen at a given time
    func getEventsAtCellTime(startTime:String) -> [Event]{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        var eventsAtTime = [Event]()
        
        for event in eventList {
            let start = dateFormatter.date(from: event.startTime)
            let end = dateFormatter.date(from: event.endTime)
            let startTimeDate = dateFormatter.date(from: startTime)
            
            // Checks if current cell block applies
            if event.startTime == startTime {
                eventsAtTime.append(event)
            }
            
            // Check if this cells occurs between start time and end time
            if start! < startTimeDate! && end! > startTimeDate! {
                eventsAtTime.append(event)
            }
        }
        
        // Sort from longest duration, to shortest
        eventsAtTime.sort {
            dateFormatter.date(from:$0.endTime)! >= dateFormatter.date(from:$1.endTime)!
        }
        
        return eventsAtTime
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "CreateEventSegue",
            let nextVC = segue.destination as? CreateEventViewController {
             nextVC.delegate = self
    
             let queue = DispatchQueue(label: "curr")
             queue.async {
                 while (self.currGroup == nil){
                     sleep(1)
                 }
                 nextVC.currGroup = self.currGroup
             }
         }
         
         // Check if we are navigating to the group settings
         if segue.identifier == "GroupSettingsSegue",
            let destination = segue.destination as? GroupSettingsViewController {
             destination.delegate = self
             destination.group = currGroup
         }
         
         // Check if we are navigating to the event 1 details
         if segue.identifier == "eventOneSegue" && currCell != nil,
            let destination = segue.destination as? EventDetailsViewController {
             destination.delegate = self
             destination.event = currCell.eventOne
             destination.currGroup = currGroup
             destination.cell = currCell
             destination.eventBlockNum = 1
         }
         
         // Check if we are navigating to the event 2 details
         if segue.identifier == "eventTwoSegue" && currCell != nil,
            let destination = segue.destination as? EventDetailsViewController {
             destination.delegate = self
             destination.event = currCell.eventTwo
             destination.currGroup = currGroup
             destination.cell = currCell
             destination.eventBlockNum = 2
         }
         
         // Check if we are navigating to the event 3 details
         if segue.identifier == "singleEvent3" && currCell != nil && currCell.eventThree.count == 1,
            let destination = segue.destination as? EventDetailsViewController {
             destination.delegate = self
             destination.event = currCell.eventThree[0]
             destination.currGroup = currGroup
             destination.cell = currCell
             destination.eventBlockNum = 3
         }
         
         // Check if we are navigating to the event 3 details
         if segue.identifier == "eventsListSegue" && currCell != nil && currCell.eventThree.count > 1,
            let destination = segue.destination as? EventListViewController {
             destination.delegate = self
             destination.events = currCell.eventThree
             destination.currGroup = currGroup
         }
         
     }
    
    // Function that retrieves events from DB to repopulate eventList for the stack
    func rePopulateEventStack() {
        //gets current group from db
        let groupRef = db.collection("Groups").document(currGroup.groupHASH)
        groupRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                    
                //gets events from "events" attribute in group
                let groupEvents = data!["events"] as! [String]
                    
                for event in groupEvents {
                    //matches event from Groups attributes with events from "Events" db
                    let eventRef = self.db.collection("Events").document(event)
                        
                    eventRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let eventData = document.data()
                            let newEvent = Event(eventName: eventData!["name"] as! String,
                                                 eventDate: eventData!["eventDate"] as! String,
                                                 startTime: eventData!["startTime"] as! String,
                                                 endTime: eventData!["endTime"] as! String,
                                                 location: eventData!["location"] as! String,
                                                 notifications: eventData!["notifications"] as! Bool,
                                                 reminderChoice: eventData!["reminderChoice"] as! String,
                                                 editEvents: eventData!["editable"] as! Bool,
                                                 eventCreator: eventData!["creator"] as! String,
                                                 nameOfGroup: eventData!["groupName"] as! String,
                                                 listOfAttendees: eventData!["attendees"] as! [String],
                                                 eventHash: eventData!["uid"] as! String,
                                                 groupHash: eventData!["groupHash"] as! String,
                                                 eventColor: eventData!["eventColor"] as! [Int]
                                            )
                            
                            let today = Date()
                            let weekday = Calendar.current.component(.weekday, from: today)
                            let month = Calendar.current.component(.month, from: today)
                            let date = Calendar.current.component(.day, from: today)

                            let weekdayText = Calendar.current.shortWeekdaySymbols[weekday-1]
                            let monthText = "\(Calendar.current.shortMonthSymbols[month-1]) \(date)"
                            
                            let todayCheck = "\(weekdayText) \(monthText)"
                            if newEvent.eventDate == todayCheck {
                                self.addNewEvent(newEvent: newEvent)
                            } else {
                                //delete event from all user accepted
                                self.deleteEventFromUsers(newEvent: newEvent)
                                //delete event from groups
                                //TODO
                                self.deleteEventFromGroups(newEvent: newEvent)
                                //delete event from events
                                self.db.collection("Events").document(newEvent.eventHash).delete()
                            }
                            
                        } else {
                            print("Event does not exist")
                        }
                    }
                }
            } else {
                print("Group does not exist")
            }
        }
    }
    
    // Function that deletes event from all attendees accepted events
    func deleteEventFromUsers(newEvent: Event){
        for attendee in newEvent.listOfAttendees {
            db.collection("Users").document(attendee).updateData([
                "events": FieldValue.arrayRemove([newEvent.eventHash])
            ])
        }
    }
    
    // Function that deletes event from group
    func deleteEventFromGroups(newEvent: Event){
        self.db.collection("Groups").document(newEvent.groupHash).updateData([
            "events": FieldValue.arrayRemove([newEvent.eventHash])
        ])
    }
    
    // Adds event to local list
    func addNewEvent(newEvent: Event) {
        eventList.append(newEvent)
        eventStack.reloadData()
    }
    
    // Deletes event from local list
    func deleteEvent(event: Event) {
        if let index = eventList.firstIndex(of:event) {
            eventList.remove(at: index)
        }
        eventStack.reloadData()
    }
    
    // Updates event in local list
    func updateEvent(cell: StackTableViewCell, event: Event) {
        let indexPath = self.eventStack.indexPath(for: cell)
//        eventStack.reloadRows(at: [indexPath], with: .top)
        if let elem = eventList.first(where: {$0.eventHash == event.eventHash}) {
            elem.eventName = event.eventName
            elem.startTime = event.startTime
            elem.endTime = event.endTime
            elem.location = event.location
        }
//        eventStack.reloadData()
    }
    
    // Updates currGroup to get the new edits set
    func updateGroup(group: Group) {
        currGroup = group
        let myNormalAttributedTitle = NSAttributedString(string: self.currGroup.groupName,
            attributes: [NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: 17)!])
        self.groupNameLabel.setAttributedTitle(myNormalAttributedTitle, for: .normal)
    }
         
}

