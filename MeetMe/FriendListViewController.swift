//
//  FriendListViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var usersList: [User] = []
    
    let db = Firestore.firestore()

    let UserCellIdentifier = "Cell"
    var group: Group!
    var loaded: Bool = false
    
    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        let queue = DispatchQueue(label: "curr")
        queue.async {
            while (!self.loaded){
                sleep(1)
            }
            self.populateFriendTable()
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = usersList[indexPath.row]
        db.collection("Groups").document(group.groupHASH).updateData(["peopleInGroup": FieldValue.arrayUnion([selectedUser.hash])])
        db.collection("Users").document(selectedUser.hash).updateData(["groupsAll": FieldValue.arrayUnion([group.groupHASH])])
    }

    func populateFriendTable() {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                    let nameRef = db.collection("Users").document(uid)
                
                    nameRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let friends = data!["friends"] as! [String]
                            for friend in friends{
                                let friendRef = self.db.collection("Users").document(friend)
                                
                                friendRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let firnedsData = document.data()
                                        let name = firnedsData!["name"] as! String
                                        let username = firnedsData!["username"] as! String
                                        let hash = firnedsData!["uid"] as! String
                                        let newUser = User(name: name, username: username, hash: hash)
                                        self.usersList.append(newUser)
                                        self.friendsTableView.reloadData()
                                        print(name)
                                    } else {
                                        print("Friend does not exist")
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
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellIdentifier, for: indexPath) as! AddFriendTableViewCell
        let row = indexPath.row
        let user = usersList[row]
        cell.nameLabel.text = user.name
        cell.usernameLabel.text = user.username
        return cell
    }
}
