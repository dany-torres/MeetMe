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

class GroupStackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddNewEvent {
    public var eventList:[Event] = []
    var delegate: UITableView!
//    var currGroupHASH : String!
//    var currGroupName : String!
    var currGroup: Group!
    var loaded: Bool = false
    
    var halfHours:[String] = []
    
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
        
//        groupNameLabel.setTitle(currGroupName, for: .normal)
        setDayLabel()
        initTime()
        
        let queue = DispatchQueue(label: "curr")
        queue.async {
            while (!self.loaded){
                sleep(1)
            }
            DispatchQueue.main.async {
                self.groupNameLabel.setTitle(self.currGroup.groupName, for: .normal)
            }
            self.rePopulateEventStack()
        }
    }
    
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
    
    // Sets the dat label to the current day
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return halfHours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stackCell", for: indexPath) as! StackTableViewCell
        let row = indexPath.row
        let time = halfHours[row]
        cell.time.text = time
        let events = getEventsAtCellTime(startTime: time)
        setEvents(cell:cell, events:events)
        return cell
    }
    
    // Set the events block in the cells accordingly
    func setEvents(cell:StackTableViewCell, events:[Event]) {
        hideUnusedEvents(cell:cell)
        switch events.count {
        case 1:
            setFirstEventBlock(cell:cell, event:events[0])
        case 2:
            setFirstEventBlock(cell:cell, event:events[0])
            setSecondEventBlock(cell:cell, event:events[1])
        case 3:
            setFirstEventBlock(cell:cell, event:events[0])
            setSecondEventBlock(cell:cell, event:events[1])
            setThirdEventBlock(cell:cell, event:events[2])
        default:
            if events.count > 3 {
                setFirstEventBlock(cell:cell, event:events[0])
                setSecondEventBlock(cell:cell, event:events[1])
                setMoreThanThreeEvents(cell:cell, extraEvents:events.count - 2)
            }
            break
        }
    }
    
    // Set the first event block
    func setFirstEventBlock(cell:StackTableViewCell, event:Event){
        cell.event1.isHidden = false
        cell.event1.text = event.eventName
    }
    
    // Set the second event block
    func setSecondEventBlock(cell:StackTableViewCell, event:Event){
        cell.event2.isHidden = false
        cell.event2.text = event.eventName
    }
    
    // Set the third event block
    func setThirdEventBlock(cell:StackTableViewCell, event:Event){
        cell.event3.isHidden = false
        cell.event3.text = event.eventName
    }
    
    // Set the third event block when there are more events
    func setMoreThanThreeEvents(cell:StackTableViewCell, extraEvents:Int){
        cell.event3.isHidden = false
        cell.event3.text = String(extraEvents) + " More Events"
    }
    
    
    // Hide any event blocks that are not being used
    func hideUnusedEvents(cell:StackTableViewCell) {
        cell.event1.isHidden = true
        cell.event2.isHidden = true
        cell.event3.isHidden = true
    }
    
    
    // Get all events that start at a given time
    func getEventsAtCellTime(startTime:String) -> [Event]{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        var eventsAtTime = [Event]()
        
        for event in eventList {
            let start = dateFormatter.date(from: event.startTime)
            let end = dateFormatter.date(from: event.endTime)
            let startTimeDate = dateFormatter.date(from: startTime)
            
            if event.startTime == startTime {
                eventsAtTime.append(event)
            }
            
            if start! < startTimeDate! && end! > startTimeDate! {
                eventsAtTime.append(event)
                // TODO: fix so that it looks like one event box
            }
        }
        
        return eventsAtTime
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "CreateEventSegue",
            let nextVC = segue.destination as? CreateEventViewController {
             nextVC.delegate = self
//           TODO: PASS THE HASH AND THE NAME OF THE GROUP SEGUE
             let queue = DispatchQueue(label: "curr")
             queue.async {
                 while (self.currGroup == nil){
                     sleep(1)
                 }
//                 nextVC.hashGroup = self.currGroupHASH
//                 nextVC.nameGroup = self.currGroupName
                 nextVC.currGroup = self.currGroup
             }
         }
     }
    
    func rePopulateEventStack(){
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
                                                 polls: eventData!["polls"] as! Bool,
                                                 messages: eventData!["messages"] as! Bool,
                                                 editEvents: eventData!["editable"] as! Bool,
                                                 eventCreator: eventData!["creator"] as! String,
                                                 nameOfGroup: eventData!["groupName"] as! String,
                                                 listOfAttendees: eventData!["attendees"] as! [String],
                                                 eventHash: eventData!["uid"] as! String
                            )
                            self.addNewEvent(newEvent: newEvent)
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
    
    func addNewEvent(newEvent: Event) {
        eventList.append(newEvent)
        eventStack.reloadData()
//        for event in eventList{
//            print(event.eventName)
//        }
    }
         
}
