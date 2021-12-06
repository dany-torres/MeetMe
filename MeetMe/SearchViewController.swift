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
                    let location = data["location"] as! String
                    let image = data["img"] as? String ?? ""
                    let newUser = User(name: name, username: username, hash: hash, location: location, image: image)
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
        
        cell.delegate = self
        
        let row = indexPath.row
        let searchedUser = usersList[row]
        cell.nameLabel.text = searchedUser.name
        cell.usernameLabel.text = "@" + searchedUser.username
        cell.locationLabel.text = searchedUser.location
        
        // Make image a circle
        cell.userImage.layer.borderWidth = 1
        cell.userImage.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
        cell.userImage.clipsToBounds = true
        
        // Set Picture
        let uid = searchedUser.hash
        setPicture(uid:uid, cell:cell)
        
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

    // Sets user picture within cell
    func setPicture(uid:String, cell:UserRequestTableViewCell){
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
                cell.userImage.image = image
            }
        })
        task.resume()
    }
    
    //when button is clicked, add the uid of curr user to clicked users friend request list
    //when loading the table view, we want to set the title of the button based on wether the searched user is in
    //the currents friendrequest list or friend list
    //case 1: searched user is in friendreq list && not in friends list -> button label: requested
    //case 2: searched user is not in friendreq list && not in friends list -> button label: add
    //case 3: searched user is not in friendreq list and in friends list -> button label: friends
    
    func didTapButton(cell: UserRequestTableViewCell) {
        print("*****AT BEGINNING OF DID TAP METHOD")
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
