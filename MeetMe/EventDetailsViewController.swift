//
//  EventDetailsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/20/21.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventCreatorPicture: UIImageView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var attendeesTableView: UITableView!
    
    
    var event:Event? = nil
    var currGroup: Group!
    
    var delegate: UIViewController!

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldsInfo()
    }
    
    // Set event info on text fields, make it uneditable
    func setTextFieldsInfo(){
        eventNameLabel.text! = event!.eventName
        dateTextField.text! = event!.eventDate
        locationTextField.text! = event!.location

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let start = dateFormatter.date(from: event!.startTime)
        let end = dateFormatter.date(from: event!.endTime)
        
        startTimePicker.date = start!
        endTimePicker.date = end!
        
        eventNameLabel.isUserInteractionEnabled = false
        locationTextField.isUserInteractionEnabled = false
        startTimePicker.isUserInteractionEnabled = false
        endTimePicker.isUserInteractionEnabled = false
        
    }
    
    // Make fields editable if the user has permission
    @IBAction func editButtonClicked(_ sender: Any) {
        // TODO: hacerlo mejor en view did load y hide el edit si no tienen permiso
        // check if admin run and editable del event
        if (!currGroup.adminRun && (event!.editEvents)) ||
            (currGroup.adminRun && currGroup.groupCreator == Auth.auth().currentUser!.uid) {
            eventNameLabel.isUserInteractionEnabled = true
            startTimePicker.isUserInteractionEnabled = true
            endTimePicker.isUserInteractionEnabled = true
            locationTextField.isUserInteractionEnabled = true
        }
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
        event?.eventName = eventNameLabel.text!
        event?.location = locationTextField.text!
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let start = dateFormatter.string(from: startTimePicker.date)
        let end = dateFormatter.string(from: endTimePicker.date)
        
        event?.startTime = start
        event?.endTime = end
        
        // Update event in database
        let eventDB : [String: Any] = [
            "eventName": eventNameLabel.text!,
            "location": locationTextField.text!,
            "startTime": start,
            "endTime": end
        ]
        self.db.collection("Events").document(event!.eventHash).updateData(eventDB)
    }

}
