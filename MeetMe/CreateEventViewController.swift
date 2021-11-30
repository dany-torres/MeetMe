//
//  CreateEventViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/12/21.
//

import UIKit
import Firebase

class CreateEventViewController: UIViewController {

    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var createEventLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var pollsButton: UIButton!
    @IBOutlet weak var editEventButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    let db = Firestore.firestore()
    
    var reminderChoice = ""
    var startTimeChosen = ""
    var endTimeChosen = ""
    
    //passes groups hash and name event belongs to
//    var hashGroup: String!
//    var nameGroup: String!
    var currGroup: Group!
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up button images for selected state
        let checkmark = UIImage(systemName: "checkmark.square")
        let square = UIImage(systemName: "square")
        notificationsButton.setImage(checkmark, for: .selected)
        notificationsButton.setImage(square, for: .normal)
        
        pollsButton.setImage(checkmark, for: .selected)
        pollsButton.setImage(square, for: .normal)
        
        editEventButton.setImage(checkmark, for: .selected)
        editEventButton.setImage(square, for: .normal)
        
        messagesButton.setImage(checkmark, for: .selected)
        messagesButton.setImage(square, for: .normal)
        
        // Setting up the curr date for date label
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let month = Calendar.current.component(.month, from: today)
        let date = Calendar.current.component(.day, from: today)

        let weekdayText = Calendar.current.shortWeekdaySymbols[weekday-1]
        let monthText = "\(Calendar.current.shortMonthSymbols[month-1]) \(date)"
        
        currentDateLabel.text = "\(weekdayText) \(monthText)"
    }
    
    @IBAction func setReminderButtonPressed(_ sender: Any) {
        
        //this will prompt an action sheet where
        //the user can pick how many hours/minutes before to send the people in the event reminders that the event is about to start
        
        let controller = UIAlertController(
            title: "Remind your friends about your event",
            message: "Choose a time:",
            preferredStyle: .actionSheet)
        
        let atTimeAction = UIAlertAction(
            title: "At time of event",
            style: .default,
            handler: {(action) in self.reminderChoice = "At time of event"})
        controller.addAction(atTimeAction)
        
        let fifteenAction = UIAlertAction(
            title: "15 minutes before",
            style: .default,
            handler: {(action) in self.reminderChoice = "15 minutes before"})
        controller.addAction(fifteenAction)
        
        let thirtyAction = UIAlertAction(
            title: "30 minutes before",
            style: .default,
            handler: {(action) in self.reminderChoice = "30 minutes before"})
        controller.addAction(thirtyAction)
        
        let oneHourAction = UIAlertAction(
            title: "1 hour before",
            style: .default,
            handler: {(action) in self.reminderChoice = "1 hour before"})
        controller.addAction(oneHourAction)
        
        let twoHoursAction = UIAlertAction(
            title: "No Reminder",
            style: .destructive,
            handler: {(action) in self.reminderChoice = "No Reminder"})
        controller.addAction(twoHoursAction)
        
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func notificationsBoxPressed(_ sender: Any) {
        
        if(notificationsButton.isSelected){
            notificationsButton.isSelected = false
        }else{
            notificationsButton.isSelected = true
        }
        
    }
    
    @IBAction func pollsBoxPressed(_ sender: Any) {
        if(pollsButton.isSelected){
            pollsButton.isSelected = false
        }else{
            pollsButton.isSelected = true
        }
    }
    
    @IBAction func editBoxPressed(_ sender: Any) {
        if(editEventButton.isSelected){
            editEventButton.isSelected = false
        }else{
            editEventButton.isSelected = true
        }
    }
    
    @IBAction func messagesBoxPressed(_ sender: Any) {
        if(messagesButton.isSelected){
            messagesButton.isSelected = false
        }else{
            messagesButton.isSelected = true
        }
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        switch true {
        case eventNameTextField.text == "":
                let controller = UIAlertController(
                    title: "Missing Event Name",
                    message: "Please name your event",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                                        title: "OK",
                                        style: .default,
                                        handler: nil))
                present(controller,
                        animated: true,
                        completion: nil)
        case locationTextField.text == "":
                let controller = UIAlertController(
                    title: "Missing location",
                    message: "Please give your event a location",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                                        title: "OK",
                                        style: .default,
                                        handler: nil))
                present(controller,
                        animated: true,
                        completion: nil)
        
        case startTimeChosen == "":
                let controller = UIAlertController(
                    title: "Missing Start Time",
                    message: "Please give your event a starting time",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                                        title: "OK",
                                        style: .default,
                                        handler: nil))
                present(controller,
                        animated: true,
                        completion: nil)
            
        case endTimeChosen == "":
                let controller = UIAlertController(
                    title: "Missing End Time",
                    message: "Please give your event an ending time",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                                        title: "OK",
                                        style: .default,
                                        handler: nil))
                present(controller,
                        animated: true,
                        completion: nil)
            
        case startTimePicker.date > endTimePicker.date:
            let controller = UIAlertController(
                title: "Incorrect End Time",
                message: "The event end time can't be set before the start time",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
            present(controller,
                    animated: true,
                    completion: nil)
        
        default:
        
            let otherVC = delegate as! AddNewEvent
        
            if Auth.auth().currentUser != nil {
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    // Create hash of the groups object
                    var hasher = Hasher()
                    hasher.combine(eventNameTextField.text)
                    hasher.combine(locationTextField.text)
                    let hash = String(hasher.finalize())
                
                    let queue = DispatchQueue(label: "curr")
                    queue.async {
                        while (self.currGroup == nil){
                            sleep(1)
                        }
                        
                        // Create the instance object
                        DispatchQueue.main.async {
                            let eventDb : [String: Any] = [
                                "uid": hash,
                                "name": self.eventNameTextField.text!,
                                "eventDate" : self.currentDateLabel.text!,
                                "startTime" : self.startTimeChosen,
                                "endTime"   : self.endTimeChosen,
                                "notifications" : self.notificationsButton.isSelected,
                                "reminderChoice" : self.reminderChoice,
                                "polls" : self.pollsButton.isSelected,
                                "messages" : self.messagesButton.isSelected,
                                "editable" : self.editEventButton.isSelected,
                                "creator": uid,
                                "groupName": self.currGroup.groupName,
                                "location": self.locationTextField.text!,
                                "attendees": [uid],
                                "groupHash": self.currGroup.groupHASH
                            ]
                            // Adds new event to Events db
                            self.db.collection("Events").document(hash).setData(eventDb)
                        }
                        // Adds new event to list of events in current group
                        self.db.collection("Groups").document(self.currGroup.groupHASH).updateData(["events": FieldValue.arrayUnion([hash])])
                        // Adds new event to list of events in current user
                        self.db.collection("Users").document(uid).updateData(["events": FieldValue.arrayUnion([hash])])
                        //creates new event object
                        DispatchQueue.main.async {
                            let newEvent = Event(eventName:self.eventNameTextField.text!,
                                         eventDate:self.currentDateLabel.text!,
                                         startTime:self.startTimeChosen,
                                         endTime:self.endTimeChosen,
                                         location:self.locationTextField.text!,
                                         notifications: self.notificationsButton.isSelected,
                                         reminderChoice: self.reminderChoice,
                                         polls: self.pollsButton.isSelected,
                                         messages:self.messagesButton.isSelected,
                                         editEvents:self.editEventButton.isSelected,
                                         eventCreator: uid,
                                         nameOfGroup: self.currGroup.groupName,
                                         listOfAttendees: [uid],
                                        eventHash: hash)
                            // Adds new event object locally
                            otherVC.addNewEvent(newEvent: newEvent)
                        }
                    }
                _ = navigationController?.popViewController(animated: true)
            }
        }
        }
    }
    
    @IBAction func startTimeChosen(_ sender: Any) {
        let timeChosen = startTimePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        startTimeChosen = dateFormatter.string(from: timeChosen)
    }
    
    @IBAction func endTimeChosen(_ sender: Any) {
        let timeChosen = endTimePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        endTimeChosen = dateFormatter.string(from: timeChosen)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //WE ARE GOING TO HAVE TO HAVE TO PASS ALL OF THE INFO TO THE STACK PAGE
    }
    */
    
    
    // code to enable tapping on the background to remove software keyboard
        func textFieldShouldReturn(textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }

}
