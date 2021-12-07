//
//  MyStackViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class MyStackViewController:  UIViewController, UITableViewDataSource,
                              UITableViewDelegate, DeleteEvent,
                              UpdateEvent, MyStackDelegate {
    
    var fetchedEvents:[Event] = []
    
    var halfHours:[String] = []
    var currCell:MyStackTableViewCell!
    
    var delegate: UITableView!
    
    let db = Firestore.firestore()

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var displayPicture: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var myStack: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myStack.delegate = self
        myStack.dataSource = self
        
        locationLabel.text! = "📍 "
        setDayLabel()
        setUserInfo()
        setUserPicture()
        initTime()
        
        // Make image a circle
        displayPicture.layer.borderWidth = 1
        displayPicture.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        displayPicture.layer.cornerRadius = displayPicture.frame.height/2
        displayPicture.clipsToBounds = true
        
        // Set array of accepted events
        if Auth.auth().currentUser != nil {
            let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        let events = data["events"] as! [String]
                        
                        // Iterate accepted events to create local array
                        for event in events {
                            // Get event info from DB
                            let eventRef = self.db.collection("Events").document(event)
                            eventRef.getDocument { [self] (document, error) in
                            if let document = document, document.exists {
                                    let eventData = document.data()
                                    let newEvent = Event(eventName: eventData!["name"] as! String,
                                                         eventDate: eventData!["eventDate"] as! String,
                                                         startTime: eventData!["startTime"] as! String,
                                                         endTime: eventData!["endTime"] as! String,
                                                         location: eventData!["location"] as! String,
                                                         reminderChoice: eventData!["reminderChoice"] as! String,
                                                         editEvents: eventData!["editable"] as! Bool,
                                                         eventCreator: eventData!["creator"] as! String,
                                                         nameOfGroup: eventData!["groupName"] as! String,
                                                         listOfAttendees: eventData!["attendees"] as! [String],
                                                         eventHash: eventData!["uid"] as! String,
                                                         groupHash: eventData!["groupHash"] as! String,
                                                         eventColor: eventData!["eventColor"] as! [Int]
                                                    )
                                
                                    // Check if event is for the current date
                                    if newEvent.eventDate == self.getTodaysDate() {
                                        self.addEventLocally(newEvent: newEvent)
                                    } else {
                                        // Event is old, remove from DB
                                        self.db.collection("Events").document(event).delete()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
            
    // Function that adds event to fetched events
    func addEventLocally(newEvent: Event){
        print("ADDED EVENTS TO FETCHED EVENTS")
        fetchedEvents.append(newEvent)
        myStack.reloadData()
    }
            
    // Func that gets today's date formatted string
    func getTodaysDate() -> String {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let month = Calendar.current.component(.month, from: today)
        let date = Calendar.current.component(.day, from: today)

        let weekdayText = Calendar.current.shortWeekdaySymbols[weekday-1]
        let monthText = "\(Calendar.current.shortMonthSymbols[month-1]) \(date)"
        
        let todayCheck = "\(weekdayText) \(monthText)"
        return todayCheck
    }
    
    
    // Sets the name, location and picture fields
    func setUserInfo(){
        if Auth.auth().currentUser != nil {
            let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        print("data", data)
                        self.nameLabel.text! = data["name"] as? String ?? ""
                        self.locationLabel.text! += data["location"] as? String ?? ""
                    }
                }
            }
        }
    }
    
    // Function that sets the user's picture
    func setUserPicture() {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                guard let urlString = UserDefaults.standard.value(forKey: uid) as? String,
                      let url = URL(string: urlString) else {
                          return
                      }
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.displayPicture.image = image
                    }
                })
                task.resume()
            }
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
        myStack.reloadData()
    }
    
    // Create rows for all half hours of the day
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return halfHours.count
    }
    
    // Populate cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myStackCell", for: indexPath) as! MyStackTableViewCell
        let row = indexPath.row
        let time = halfHours[row]
        
        // Set time and delegate for cell
        cell.time.text = time
        cell.delegate = self
//        cell.button1.isEnabled = false
//        cell.button2.isEnabled = false
//        cell.button3.isEnabled = false
//        print("***cell.button1 is enabled? \(cell.button1.isEnabled)")
        
        // Get the events that happen at the current cell time
        let events = getEventsAtCellTime(startTime: time)
        setEvents(cell:cell, events:events)
        
        return cell
    }
    
    // Check if the first event button was clicked
    func didTapCellButton1MyStack(cell: MyStackTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.myStack.indexPath(for: cell)
        let cell = myStack.cellForRow(at: indexPath!) as! MyStackTableViewCell
        currCell = cell
    }
    
    // Check if the second event button was clicked
    func didTapCellButton2MyStack(cell: MyStackTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.myStack.indexPath(for: cell)
        let cell = myStack.cellForRow(at: indexPath!) as! MyStackTableViewCell
        currCell = cell
    }
    
    // Check if the third event button was clicked
    func didTapCellButton3MyStack(cell: MyStackTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.myStack.indexPath(for: cell)
        let cell = myStack.cellForRow(at: indexPath!) as! MyStackTableViewCell
        currCell = cell
        
        if (currCell != nil && currCell.eventThree.count == 1) {
            self.performSegue(withIdentifier: "event3Segue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "toEventListSegue", sender: nil)
        }
    }
    
    // Set the events block in the cells accordingly
    func setEvents(cell:MyStackTableViewCell, events:[Event]) {
        hideUnusedEvents(cell:cell)
        switch events.count {
        case 1:
            cell.button1.isHidden = false
            cell.button1.isEnabled = true
            setFirstEventBlock(cell:cell, event:events[0])
        case 2:
            cell.button1.isEnabled = true
            cell.button1.isHidden = false
            cell.button2.isEnabled = true
            cell.button2.isHidden = false
            setFirstEventBlock(cell:cell, event:events[0])
            setSecondEventBlock(cell:cell, event:events[1])
        case 3:
            cell.button1.isEnabled = true
            cell.button1.isHidden = false
            cell.button2.isEnabled = true
            cell.button2.isHidden = false
            cell.button3.isEnabled = true
            cell.button3.isHidden = false
            setFirstEventBlock(cell:cell, event:events[0])
            setSecondEventBlock(cell:cell, event:events[1])
            setThirdEventBlock(cell:cell, event:events[2])
        default:
            cell.button1.isEnabled = true
            cell.button1.isHidden = false
            cell.button2.isEnabled = true
            cell.button2.isHidden = false
            cell.button3.isEnabled = true
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
    func setFirstEventBlock(cell:MyStackTableViewCell, event:Event){
        cell.event1.isHidden = false
        cell.button1.isEnabled = true
        // Check if not a longer event
        if event.startTime == cell.time.text {
            cell.event1.text = event.eventName
        }
        cell.eventOne = event
    }
    
    // Set the second event block
    func setSecondEventBlock(cell:MyStackTableViewCell, event:Event){
        cell.event2.isHidden = false
        cell.button2.isEnabled = true
        if event.startTime == cell.time.text {
            cell.event2.text = event.eventName
        }
        cell.eventTwo = event
    }
    
    // Set the third event block
    func setThirdEventBlock(cell:MyStackTableViewCell, event:Event){
        cell.event3.isHidden = false
        cell.button3.isEnabled = true
        if event.startTime == cell.time.text {
            cell.event3.text = event.eventName
        }
        cell.eventThree = [event]
    }
    
    // Set the third event block when there are more events
    func setMoreThanThreeEvents(cell:MyStackTableViewCell, extraEvents:[Event]){
        cell.event3.isHidden = false
        cell.button3.isEnabled = true
        cell.event3.text = String(extraEvents.count) + " More Events"
        cell.eventThree = extraEvents
    }
    
    // Hide any event blocks that are not being used
    func hideUnusedEvents(cell:MyStackTableViewCell) {
        cell.event1.isHidden = true
        cell.event2.isHidden = true
        cell.event3.isHidden = true
        cell.button1.isHidden = true
        cell.button2.isHidden = true
        cell.button3.isHidden = true
    }
    
    // Get all events that start at a given time
    func getEventsAtCellTime(startTime:String) -> [Event]{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        var eventsAtTime = [Event]()
        
        for event in fetchedEvents {
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
         // Check if we are navigating to the event 1 details
         if segue.identifier == "event1Segue" && currCell != nil,
            let destination = segue.destination as? EventDetailsViewController {
             destination.delegate = self
             destination.event = currCell.eventOne
//             destination.cell = currCell as? StackTableViewCell
             destination.eventBlockNum = 1
         }
         
         // Check if we are navigating to the event 2 details
         if segue.identifier == "event2Segue" && currCell != nil,
            let destination = segue.destination as? EventDetailsViewController {
             destination.delegate = self
             destination.event = currCell.eventTwo
//             destination.cell = currCell as? StackTableViewCell
             destination.eventBlockNum = 2
         }
         
         // Check if we are navigating to the event 3 details
         if segue.identifier == "event3Segue" && currCell != nil && currCell.eventThree.count == 1,
            let destination = segue.destination as? EventDetailsViewController {
             destination.delegate = self
             destination.event = currCell.eventThree[0]
//             destination.cell = currCell as? StackTableViewCell
             destination.eventBlockNum = 3
         }
         
         // Check if we are navigating to the event 3 details
         if segue.identifier == "toEventListSegue" && currCell != nil && currCell.eventThree.count > 1,
            let destination = segue.destination as? EventListViewController {
             destination.delegate = self
             destination.events = currCell.eventThree
//             destination.cell = currCell as? StackTableViewCell
         }
         
     }
    
    // Deletes event from local list
    func deleteEvent(event: Event) {
        if let index = fetchedEvents.firstIndex(of:event) {
            fetchedEvents.remove(at: index)
        }
        myStack.reloadData()
    }
    
    // Updates event in local list
    func updateEvent(event: Event) {
        if let elem = fetchedEvents.first(where: {$0.eventHash == event.eventHash}) {
            elem.eventName = event.eventName
            elem.startTime = event.startTime
            elem.endTime = event.endTime
            elem.location = event.location
        }
        myStack.reloadData()
    }
}
