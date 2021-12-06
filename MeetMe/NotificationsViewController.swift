//
//  NotificationsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate {

    @IBOutlet weak var friendRequestTableView: UITableView!
    @IBOutlet weak var upcomingEventsTableView: UITableView!
    
    var delegate: UIViewController!
    var user:User? = nil
    var eventList: [Event] = []
    var friendRequesList: [User] = []
    var currCell: FriendRequestTableViewCell!
    var loaded: Bool = false
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendRequestTableView.delegate = self
        friendRequestTableView.dataSource = self
        friendRequestTableView.layer.borderWidth = 0.5
        friendRequestTableView.layer.cornerRadius = 10
        friendRequestTableView.layer.borderColor = UIColor(red: 208/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        
        upcomingEventsTableView.delegate = self
        upcomingEventsTableView.dataSource = self
        upcomingEventsTableView.layer.borderWidth = 0.5
        upcomingEventsTableView.layer.cornerRadius = 10
        upcomingEventsTableView.layer.borderColor = UIColor(red: 208/255, green: 204/255, blue: 204/255, alpha: 1).cgColor

        //populate event list and friend request list from database
        
        let queue = DispatchQueue(label: "curr")
        queue.async {
//            while (self.eventList == []){
//                sleep(1)
//
//            }
            DispatchQueue.main.async {
                self.populateFriendRequestTable()
                self.populateUpcomingEventsTable()
            }
        }

        
        upcomingEventsTableView.reloadData()

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
                                        let location = friendReqData!["location"] as! String
                                        let image = friendReqData!["img"] as? String ?? ""
                                        let newFriendReq = User(name: name, username: username, hash: hash, location: location, image: image)
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
                                let eventRef = self.db.collection("Events").document(event)
                                
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
                                        print("Upcoming event does not exist")
                                    }
                                }
                            }
                        }else {
                            print("User does not exist")
                        }
                    }
            }
        }
        
        print(self.eventList.count)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
            
            case friendRequestTableView:
                return friendRequesList.count
                
            case upcomingEventsTableView:
                return eventList.count
            
            default:
            return eventList.count
            
            }
        
    }
    
    //load cells with event/friend request details
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
            
            case friendRequestTableView:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestTableViewCell
                cell.delegate = self
                let row = indexPath.row
                let friend = friendRequesList[row]
                cell.name.text = friend.name
                cell.username.text = "@ \(friend.username)"
                setUserPicture(uid: friend.hash, cell: cell)
                
                // Format cell, add corners
                cell.contentView.layer.cornerRadius = 5.0
                cell.contentView.layer.masksToBounds = true
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = false
                return cell
                
            case upcomingEventsTableView:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! UpcomingEventTableViewCell
                let row = indexPath.row
                let event = eventList[row]
                
                let now = Date()
                var calendar = Calendar.current
                let formatter = DateFormatter()
                formatter.timeStyle = .short
            
                let start = formatter.date(from: event.startTime)
            
                let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: now, to: start!)
                
                //if == 0 print happening now
                //compare start dates
                let finalDate = Calendar.current.date(from:diffComponents)!
                let hour = calendar.component(.hour, from: finalDate)
                let min = calendar.component(.minute, from: finalDate)

            
                cell.upcomingEventLabel.text = "\(event.eventName) starts in \(hour) hours and \(min) minutes"
                // Make image a circle
            cell.imageView!.layer.borderWidth = 1
            cell.imageView!.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
            cell.imageView!.layer.cornerRadius = cell.imageView!.frame.height/2
            cell.imageView!.clipsToBounds = true
                // TODO: set group picture
                let uid = event.groupHash
                setPicture(uid:uid, cell:cell)
                // Format cell, add corners
                cell.contentView.layer.cornerRadius = 5.0
                cell.contentView.layer.masksToBounds = true
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = false
                
            
                return cell
            
            default:
            // TODO: CReo que ya puedes borrar esto
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! UpcomingEventTableViewCell
            let row = indexPath.row
            let event = eventList[row]
            
        
            let eventDateIntFormat: Int? = Int(event.startTime)
            let now = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            let modifiedDate = Calendar.current.date(byAdding: .hour, value: -eventDateIntFormat!, to: now)!
            
            let dateString = formatter.string(from: modifiedDate)
            cell.upcomingEventLabel.text = "\(event.eventName) starts in \(dateString)"
            return cell
            
            }
    }
    
    
    // Sets user picture within cell
    func setUserPicture(uid:String, cell:FriendRequestTableViewCell){
        // Make image a circle
        cell.userPicture.layer.borderWidth = 1
        cell.userPicture.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        cell.userPicture.layer.cornerRadius = cell.userPicture.frame.height/2
        cell.userPicture.clipsToBounds = true
        
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
                cell.userPicture.image = image
            }
        })
        task.resume()
    }
    
    // Sets user picture within cell
    func setPicture(uid:String, cell:UpcomingEventTableViewCell){
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
                cell.imageView?.image = image
            }
        })
        task.resume()
    }
    
    //method for accepting friend request
    func didTapAcceptButton(cell: FriendRequestTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.friendRequestTableView.indexPath(for: cell)
        let cell = friendRequestTableView.cellForRow(at: indexPath!) as! FriendRequestTableViewCell
        currCell = cell
        
        let row = (indexPath?.row)!
        
        //remove locally
        let newFriend = friendRequesList.remove(at: row)
        
        //remove cell
        friendRequestTableView.beginUpdates()
        friendRequestTableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        friendRequestTableView.endUpdates()
        
        //get hash of user object
        let newFriendHash = newFriend.hash
        
        
        //add new friend to current users friends array in DB
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                
                // Search for the user and append it to existing array
                self.db.collection("Users").document(uid).updateData(["friends": FieldValue.arrayUnion([newFriendHash])])
                
                //remove from friend request list in DB
                self.db.collection("Users").document(uid).updateData(["friendRequests": FieldValue.arrayRemove([newFriendHash])
                                                                     ])
                self.friendRequestTableView.reloadData()
            }
            
        } else {
          // No user is signed in.
          // ...
        }
    }
    
    //method for declining friend request
    func didTapDeclineButton(cell: FriendRequestTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.friendRequestTableView.indexPath(for: cell)
        let cell = friendRequestTableView.cellForRow(at: indexPath!) as! FriendRequestTableViewCell
        currCell = cell
        
        let row = (indexPath?.row)!
        
        //remove locally
        let personToRemove = friendRequesList.remove(at: row)
        let personToRemoveHash = personToRemove.hash
        
        
        //remove from database
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                
                self.db.collection("Users").document(uid).updateData(["friendRequests": FieldValue.arrayRemove([personToRemoveHash])
                                                                     ])
            }
            
        } else {
          // No user is signed in.
          // ...
        }
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

