//
//  NotificationsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendRequestTableView: UITableView!
    @IBOutlet weak var upcomingEventsTableView: UITableView!
    
    var delegate: UIViewController!
    var user:User? = nil
    var eventList: [Event] = []
    var friendRequesList: [User] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendRequestTableView.delegate = self
        friendRequestTableView.dataSource = self
        
        upcomingEventsTableView.delegate = self
        upcomingEventsTableView.dataSource = self
        
        
        //populate event list and friend request list from database
        populateFriendRequestTable()
        populateUpcomingEventsTable()
        
        //TODO: Add logic for when the accept and decline button are clicked
    }
    
    func populateFriendRequestTable(){
        
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                    let nameRef = db.collection("Users").document(uid)
                
                    nameRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let friendRequests = data!["friendRequests"] as! [String]
                            for friendReq in friendRequests{
                                let friendRef = self.db.collection("Users").document(friendReq)
                                
                                friendRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let friendReqData = document.data()
                                        let name = friendReqData!["name"] as! String
                                        let username = friendReqData!["username"] as! String
                                        let hash = friendReqData!["uid"] as! String
                                        let newFriendReq = User(name: name, username: username, hash: hash)
                                        self.friendRequesList.append(newFriendReq)
                                        self.friendRequestTableView.reloadData()
                                        print(name)
                                    } else {
                                        print("Friend Request does not exist")
                                    }
                                }
                            }
                        }else {
                            print("User does not exist")
                        }
                    }
            }
        }
        
    }
    
    func populateUpcomingEventsTable(){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                    let nameRef = db.collection("Users").document(uid)
                
                    nameRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let upcomingEvents = data!["events"] as! [String]
                            for event in upcomingEvents{
                                let eventRef = self.db.collection("Users").document(event)
                                
                                eventRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let eventData = document.data()
                                        let name = eventData!["name"] as! String
                                        let eventDate = eventData!["eventDate"] as! String
                                        let startTime = eventData!["startTime"] as! String
                                        let endTime = eventData!["endTime"] as! String
                                        let location = eventData!["location"] as! String
                                        let notifications = eventData!["notifications"] as! Bool
                                        let reminderChoice = eventData!["reminderChoice"] as! String
                                        let editEvents = eventData!["editable"] as! Bool
                                        let eventCreator = eventData!["creator"] as! String
                                        let nameOfGroup = eventData!["groupName"] as! String
                                        let listOfAttendees = eventData!["attendees"] as! [String]
                                        let eventHash = eventData!["uid"] as! String
                                        let groupHash = eventData!["groupHash"] as! String
                                        
                                        let newEvent = Event(eventName: name, eventDate: eventDate, startTime: startTime, endTime: endTime, location: location, notifications: notifications, reminderChoice: reminderChoice, editEvents: editEvents, eventCreator: eventCreator, nameOfGroup: nameOfGroup, listOfAttendees: listOfAttendees, eventHash: eventHash, groupHash: groupHash, eventColor:[216, 180, 252])
                                        self.eventList.append(newEvent)
                                        self.upcomingEventsTableView.reloadData()
                                        print(name)
                                    } else {
                                        print("Friend Request does not exist")
                                    }
                                }
                            }
                        }else {
                            print("User does not exist")
                        }
                    }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
            
            case friendRequestTableView:
                return friendRequesList.count
                
            case upcomingEventsTableView:
                return eventList.count
            
            default:
            
            return 0
            
            }
        
    }
    
    //load cells with event/friend request details
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
            
            case friendRequestTableView:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestTableViewCell
                let row = indexPath.row
                let friend = friendRequesList[row]
                cell.name.text = friend.name
                cell.username.text = friend.username
                return cell
                
            case upcomingEventsTableView:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! UpcomingEventTableViewCell
                let row = indexPath.row
                let event = eventList[row]
                cell.upcomingEventLabel.text = event.eventName
                return cell
            
            default:
            
            return UITableViewCell()
            
            }
    }
    
    
    
    //make method for when accept friend button is clicked
    
    
    //make method for when decline friend button is clicked
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
