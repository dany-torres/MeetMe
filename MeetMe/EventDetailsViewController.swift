//
//  EventDetailsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/20/21.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventCreatorPicture: UIImageView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var event:Event? = nil
    var currGroup: Group!
    
    var delegate: UIViewController!

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isHidden = true
        saveButton.isHidden = true
        startTimePicker.setValue(UIColor.lightGray, forKeyPath: "textColor")
        endTimePicker.setValue(UIColor.lightGray, forKeyPath: "textColor")
        
        // Check if user can't edit event
        // Case 1: Community Run AND event is editable
        // Case 2: Admin Run AND group creator is trying to edit
        if (!currGroup.adminRun && (event!.editEvents)) ||
            (currGroup.adminRun && currGroup.groupCreator == Auth.auth().currentUser!.uid) {
            editButton.isHidden = false
            saveButton.isHidden = false
        }
        
        setTextFieldsInfo()
    }
    
    // Set event info on text fields, make it uneditable
    func setTextFieldsInfo(){
        eventNameTextField.text! = event!.eventName
        dateTextField.text! = event!.eventDate
        locationTextField.text! = event!.location

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let start = dateFormatter.date(from: event!.startTime)
        let end = dateFormatter.date(from: event!.endTime)
        
        startTimePicker.date = start!
        endTimePicker.date = end!
        
        dateTextField.isUserInteractionEnabled = false
        eventNameTextField.isUserInteractionEnabled = false
        locationTextField.isUserInteractionEnabled = false
        startTimePicker.isUserInteractionEnabled = false
        endTimePicker.isUserInteractionEnabled = false
        
    }
    
    // Make fields editable if the user has permission
    @IBAction func editButtonClicked(_ sender: Any) {
        eventNameTextField.isUserInteractionEnabled = true
        startTimePicker.isUserInteractionEnabled = true
        endTimePicker.isUserInteractionEnabled = true
        locationTextField.isUserInteractionEnabled = true
        
        eventNameTextField.textColor = UIColor.black
        locationTextField.textColor = UIColor.black
        startTimePicker.setValue(UIColor.black, forKeyPath: "textColor")
        endTimePicker.setValue(UIColor.black, forKeyPath: "textColor")
    }
    
    // Add user to event's attendees and to user's accepted events
    @IBAction func joinEventButtonClicked(_ sender: Any) {
        // Add current user to event attendees
        event!.listOfAttendees.append(Auth.auth().currentUser!.uid)
    
        // Update event in database
        let eventDB : [String: Any] = [
            "listOfAttendees": event!.listOfAttendees,
        ]
        self.db.collection("Events").document(event!.eventHash).updateData(eventDB)
        
        // TODO: checar que esto funciona
        // Add event to user accepted events array
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                self.db.collection("Users").document(uid).updateData(["events": FieldValue.arrayUnion([event!.eventHash])])
            }
        } else {
          // No user is signed in.
          // ...
        }
        
    }
    
    // When the save button is pressed, the event info should be updated
    @IBAction func saveButtonPressed(_ sender: Any) {
        // check if new info is valid
        if checkNewInfo() {
            event?.eventName = eventNameTextField.text!
            event?.location = locationTextField.text!
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            let start = dateFormatter.string(from: startTimePicker.date)
            let end = dateFormatter.string(from: endTimePicker.date)
            
            event?.startTime = start
            event?.endTime = end
            
            // Update event in database
            let eventDB : [String: Any] = [
                "name": eventNameTextField.text!,
                "location": locationTextField.text!,
                "startTime": start,
                "endTime": end
            ]
            self.db.collection("Events").document(event!.eventHash).updateData(eventDB)
        }
        
        eventNameTextField.isUserInteractionEnabled = false
        locationTextField.isUserInteractionEnabled = false
        startTimePicker.isUserInteractionEnabled = false
        endTimePicker.isUserInteractionEnabled = false
        
        eventNameTextField.textColor = UIColor.lightGray
        locationTextField.textColor = UIColor.lightGray
        startTimePicker.setValue(UIColor.lightGray, forKeyPath: "textColor")
        endTimePicker.setValue(UIColor.lightGray, forKeyPath: "textColor")
        
    }
    
    // Function to check if new information is allowed
    func checkNewInfo() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
    
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
            present(controller, animated: true, completion: nil)
            return false
            
        case locationTextField.text == "":
            let controller = UIAlertController(
                                    title: "Missing location",
                                    message: "Please give your event a location",
                                    preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
            return false
        
        case dateFormatter.string(from: startTimePicker.date) == "":
            let controller = UIAlertController(
                                    title: "Missing Start Time",
                                    message: "Please give your event a starting time",
                                    preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
            return false
            
        case dateFormatter.string(from: endTimePicker.date) == "":
            let controller = UIAlertController(
                                    title: "Missing End Time",
                                    message: "Please give your event an ending time",
                                    preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
            return false
            
        case startTimePicker.date > endTimePicker.date:
            let controller = UIAlertController(
                                    title: "Incorrect End Time",
                                    message: "The event end time can't be set before the start time",
                                    preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
            return false
        case startTimePicker.date == endTimePicker.date:
            let controller = UIAlertController(
                                    title: "Incorrect End Time",
                                    message: "The event end time can't be the same as the start time",
                                    preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
            return false
        default:
            return true
        }
    }

}
