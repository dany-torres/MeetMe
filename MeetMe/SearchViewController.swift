//
//  SearchViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserRequestTableViewCellDelegate {
    
    
    var usersList: [User] = []
    
    let db = Firestore.firestore()

    let UserCellIdentifier = "UserCell"

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var currCell: UserRequestTableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        
        db.collection("Users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let name = data["name"] as! String
                    let username = data["username"] as! String
                    let hash = data["uid"] as! String
                    let newUser = User(name: name, username: username, hash: hash)
//                    self.usersList.append(newUser)
//                    self.resultsTableView.reloadData()
                    if Auth.auth().currentUser != nil {
                        let user = Auth.auth().currentUser
                        if let user = user {
                            let uid = user.uid
                            let nameRef = self.db.collection("Users").document(uid)
                            nameRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let data = document.data()
                                    var friends = data!["friends"] as! [String]
                                    friends.append(uid)
                                    if !friends.contains(newUser.hash){
                                        self.usersList.append(newUser)
                                        self.resultsTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        print(usersList)
        // Do any additional setup after loading the view.
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedUser = usersList[indexPath.row]
//        if Auth.auth().currentUser != nil {
//            let user = Auth.auth().currentUser
//            if let user = user {
//                let uid = user.uid
//                //Cambiar a FriendRequests para tener al interface
//                db.collection("Users").document(selectedUser.hash).updateData(["friends": FieldValue.arrayUnion([uid])])
//                db.collection("Users").document(uid).updateData(["friends": FieldValue.arrayUnion([selectedUser.hash])])
//            }
//        }
//    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellIdentifier, for: indexPath) as! UserRequestTableViewCell
        let row = indexPath.row
        let searchedUser = usersList[row]
        cell.nameLabel.text = searchedUser.name
        cell.usernameLabel.text = searchedUser.username
        
        //check cases and update button label
        //case 1: searched user is in friendreq list && not in friends list -> button label: requested
        //case 2: searched user is not in friendreq list && not in friends list -> button label: add
        //case 3: searched user is not in friendreq list and in friends list -> button label: friends
        
        //search for users 
        db.collection("Users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if Auth.auth().currentUser != nil {
                        let user = Auth.auth().currentUser
                        if let user = user {
                            let uid = user.uid
                            let nameRef = self.db.collection("Users").document(uid)
                            nameRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let data = document.data()
                                    let friends = data!["friends"] as! [String]
                                    let friendRequests = data!["friendRequests"] as! [String]
                                    //friends.append(uid)
                                    if (friendRequests.contains(searchedUser.hash) && !friends.contains(searchedUser.hash)) {
                                        cell.requestButton.setTitle("Requested", for: .normal)
                                        self.resultsTableView.reloadData()
                                    }
                                    if(!friendRequests.contains(searchedUser.hash) && !friends.contains(searchedUser.hash)){
                                        cell.requestButton.setTitle("Add", for: .normal)
                                        self.resultsTableView.reloadData()
                                    }
                                    if(!friendRequests.contains(searchedUser.hash) && friends.contains(searchedUser.hash)){
                                        cell.requestButton.setTitle("Added", for: .normal)
                                        self.resultsTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    //when button is clicked, add the uid of curr user to clicked users friend request list
    //when loading the table view, we want to set the title of the button based on wether the searched user is in
    //the currents friendrequest list or friend list
    //case 1: searched user is in friendreq list && not in friends list -> button label: requested
    //case 2: searched user is not in friendreq list && not in friends list -> button label: add
    //case 3: searched user is not in friendreq list and in friends list -> button label: friends
    
    func didTapButton(cell: UserRequestTableViewCell) {
        
        //Get the indexpath of cell where button was tapped
        let indexPath = self.resultsTableView.indexPath(for: cell)
        let cell = resultsTableView.cellForRow(at: indexPath!) as! UserRequestTableViewCell
        
        //check status of button
        let buttonStatus = cell.requestButton.titleLabel?.text
        print("INSIDE DELEGATE METHOD")
        if(buttonStatus == "Add"){
            
            print("INSIDE IF ADD STATEMENT")
            //change button status
            cell.requestButton.setTitle("Requested", for: .normal)
                
            currCell = cell
                    
            let row = (indexPath?.row)!
            
            let newFriendRequest = usersList[row]
            let newFriendRequestHash = newFriendRequest.hash
            
            if Auth.auth().currentUser != nil {
                
                //get current user
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    
                    
                    // Search for the curr user and add the uid of curr user to friend request list of clicked user
                    self.db.collection("Users").document(newFriendRequestHash).updateData(["friendRequests": FieldValue.arrayUnion([uid])])
                    
                    //also remove it from user list or ??
                    
                    
                }
            }
            
        }
        
        //else there is nothing to do but wait until the other person accepts the request 
                
         
        
        
    }
}
