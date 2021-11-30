//
//  MyStackViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class MyStackViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var displayPicture: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var myStack: UITableView!
    
    var halfHours:[String] = []
    var eventList:[Event] = []
    var fetchedEvents:[Event] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myStack.delegate = self
        myStack.dataSource = self
        
        locationLabel.text! = "📍 "
        setDayLabel()
        setUserInfo()
        initTime()
        
        // set array of accepted events
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
                        self.fetchedEvents = data["events"] as? Array ?? []
                    }
                }
            }
        }
        
//        print(fetchedEvents)
        self.eventList = fetchedEvents
    }
    
    // Sets the name, location and picture fields TODO: set picture
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return halfHours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myStackCell", for: indexPath) as! StackTableViewCell
        let row = indexPath.row
        let time = halfHours[row]
        cell.time.text = time
        let events = getEventsAtCellTime(startTime: time)
        setEvents(cell:cell, events:events)
        return cell
    }
    
    // function to make something unselectable
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
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

}
