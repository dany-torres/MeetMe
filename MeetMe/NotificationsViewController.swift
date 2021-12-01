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
        
        
        //populate evetn list and friend request list from database
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
