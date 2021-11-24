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
    var currGroupHASH : String!
    var currGroupName : String!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var eventStack: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change back button ot go to root rather than create group
        var viewControllersArray = [UIViewController]()
        viewControllersArray.append(self.navigationController!.viewControllers.first!)
        viewControllersArray.append(self.navigationController!.viewControllers.last!)
        self.navigationController?.setViewControllers(viewControllersArray, animated: false)
//        currGroupHASH = dummy
        eventStack.delegate = self
        eventStack.dataSource = self
        let queue = DispatchQueue(label: "curr")
        queue.async {
            while (self.currGroupHASH == nil){
                sleep(1)
            }
            self.rePopulateEventStack()
        }
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stackCell", for: indexPath)
        
        //After creating the cell, update the properties of the cell with appropriate data values.
        let row = indexPath.row
        cell.textLabel?.text = eventList[row].printEventDetails()
        return cell
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "CreateEventSegue",
            let nextVC = segue.destination as? CreateEventViewController {
             nextVC.delegate = self
//             TODO: PASS THE HASH AND THE NAME OF THE GROUP SEGUE
             let queue = DispatchQueue(label: "curr")
             queue.async {
                 while (self.currGroupHASH == nil){
                     sleep(1)
                 }
                 nextVC.hashGroup = self.currGroupHASH
                 nextVC.nameGroup = self.currGroupName
             }
         }
     }
    
    func rePopulateEventStack(){
        let groupRef = db.collection("Groups").document(currGroupHASH)
                    groupRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let groupEvents = data!["events"] as! [String]
                            
                            for event in groupEvents {
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
                                        print("Document does not exist")
                                    }
                                }
                            }
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
    
    func addNewEvent(newEvent: Event) {
            eventList.append(newEvent)
            eventStack.reloadData()
        }
         
}
