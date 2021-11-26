//
//  EventDetailsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/20/21.
//

import UIKit

class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventCreatorPicture: UIImageView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var attendeesTableView: UITableView!
    
    
    var event:Event? = nil
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Set event info on text fields, make it uneditable
    func setTextFieldsInfo(){
        dateTextField.text! = event!.eventDate
        locationTextField.text! = event!.location

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let start = dateFormatter.date(from: event!.startTime)
        let end = dateFormatter.date(from: event!.endTime)
        
        startTimePicker.date = start!
        endTimePicker.date = end!
        
        dateTextField.isUserInteractionEnabled = false
        locationTextField.isUserInteractionEnabled = false
        startTimePicker.isUserInteractionEnabled = false
        endTimePicker.isUserInteractionEnabled = false
        
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        dateTextField.isUserInteractionEnabled = true
        startTimePicker.isUserInteractionEnabled = true
        endTimePicker.isUserInteractionEnabled = true
        locationTextField.isUserInteractionEnabled = true
    }
    
    @IBAction func joinEventButtonClicked(_ sender: Any) {
        // join event, update event
        // add event to user accepted events array
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // update event info
    }

}
