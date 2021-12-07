//
//  CreateEventViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/12/21.
//

import UIKit
import Firebase
import UserNotifications

class CreateEventViewController: UIViewController {

    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var createEventLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var editEventButton: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var reminderChoicePicker: UIDatePicker!
    
    let db = Firestore.firestore()
    
    var reminderChoice = ""
    var startTimeChosen = ""
    var endTimeChosen = ""
    
    //passes groups hash and name event belongs to
//    var hashGroup: String!
//    var nameGroup: String!
    var currGroup: Group!
    var rgbArray:[Int] = []
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up button images for selected state
        let checkmark = UIImage(systemName: "checkmark.square")
        let square = UIImage(systemName: "square")
        
        editEventButton.setImage(checkmark, for: .selected)
        editEventButton.setImage(square, for: .normal)
        

        // Setting up the curr date for date label
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let month = Calendar.current.component(.month, from: today)
        let date = Calendar.current.component(.day, from: today)

        let weekdayText = Calendar.current.shortWeekdaySymbols[weekday-1]
        let monthText = "\(Calendar.current.shortMonthSymbols[month-1]) \(date)"
        
        currentDateLabel.text = "\(weekdayText) \(monthText)"
    }

    
    @IBAction func editBoxPressed(_ sender: Any) {
        if(editEventButton.isSelected){
            editEventButton.isSelected = false
        }else{
            editEventButton.isSelected = true
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
            
        case startTimePicker.date == endTimePicker.date:
            let controller = UIAlertController(
                title: "Incorrect End Time",
                message: "The event end time can't be the same as the start time",
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
                    
                    self.setRGBArray(uid:uid)
                    
                    let queue = DispatchQueue(label: "curr")
                    queue.async {
                        while (self.currGroup == nil || self.rgbArray == []){
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
                                "reminderChoice" : self.reminderChoice,
                                "editable" : self.editEventButton.isSelected,
                                "creator": uid,
                                "groupName": self.currGroup.groupName,
                                "location": self.locationTextField.text!,
                                "attendees": [uid],
                                "groupHash": self.currGroup.groupHASH,
                                "eventColor": self.rgbArray
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
                             reminderChoice: self.reminderChoice,
                             editEvents:self.editEventButton.isSelected,
                             eventCreator: uid,
                             nameOfGroup: self.currGroup.groupName,
                             listOfAttendees: [uid],
                             eventHash: hash,
                             groupHash: self.currGroup.groupHASH,
                             eventColor: self.rgbArray)
                            // Adds new event object locally
                           otherVC.addNewEvent(newEvent: newEvent)
                       }
                   }
                    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                         if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                           //contents
                             let content = UNMutableNotificationContent()
                                 content.title = "MeetMe"
                             
                             content.body = "\(self.eventNameTextField.text!) starts in \(self.reminderChoice)"
                                 content.sound = UNNotificationSound.default
                             //trigger
                             let dateInfo = Calendar.current.dateComponents([.hour,.minute], from: self.reminderChoicePicker.date)
                             let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                           //request
                             let request = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)

                             let notificationCenter = UNUserNotificationCenter.current()

                             notificationCenter.add(request) { (error) in
                                if error != nil{
                                   print("error in notification! ")
                                }
                             }
                         }
                         else {
                             print("user denied")
                         }
                     }
                    
                    _ = navigationController?.popViewController(animated: true)
                }
            }
       }
   }
    

    // Function that sets RGB array to store in event db
    func setRGBArray(uid:String){
        let docRef = db.collection("Users").document(uid)
        docRef.getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    self.rgbArray = data["rgb"] as! [Int]
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
    
    @IBAction func reminderTimeChosen(_ sender: Any) {
        let timeChosen = startTimePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        reminderChoice = dateFormatter.string(from: timeChosen)
    }
    
    // code to enable tapping on the background to remove software keyboard
        func textFieldShouldReturn(textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }

}
