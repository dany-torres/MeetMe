//
//  CreateEventViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/12/21.
//

import UIKit

class CreateEventViewController: UIViewController {

    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var createEventLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func setReminderButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func notificationsBoxPressed(_ sender: Any) {
    }
    
    @IBAction func pollsBoxPressed(_ sender: Any) {
    }
    
    @IBAction func editBoxPressed(_ sender: Any) {
    }
    
    @IBAction func messagesBoxPressed(_ sender: Any) {
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
