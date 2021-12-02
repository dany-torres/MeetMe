//
//  FriendListViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var usersList: [String] = []
    
    let db = Firestore.firestore()

    let UserCellIdentifier = "Cell"
    var delegate: UIViewController!
    var group: Group!
    var loaded: Bool = false
    var fromSettings = true
    var currentMembers: [String] = []
    
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
        if fromSettings {
            db.collection("Groups").document(group.groupHASH).updateData(["peopleInGroup": FieldValue.arrayUnion([selectedUser])])
            db.collection("Users").document(selectedUser).updateData(["groupsAll": FieldValue.arrayUnion([group.groupHASH])])
        }
        currentMembers.append(selectedUser)
        usersList = usersList.filter {$0 != selectedUser}
        let otherVC = delegate as! addFriends
        otherVC.addFriends(newUser: selectedUser)
        friendsTableView.reloadData()
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
                            var friends = data!["friends"] as! [String]
                            friends = Array(Set(friends).subtracting(self.currentMembers))
                            for friend in friends{
                                let friendRef = self.db.collection("Users").document(friend)
                                
                                friendRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let firnedsData = document.data()
                                        let hash = firnedsData!["uid"] as! String
                                        self.usersList.append(hash)
                                        self.friendsTableView.reloadData()
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
        let friendRef = self.db.collection("Users").document(user)
        friendRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let firnedsData = document.data()
                cell.nameLabel.text = firnedsData!["name"] as? String
                cell.usernameLabel.text = firnedsData!["username"] as? String
            } else {
                print("Friend does not exist")
            }
        }
        
        return cell
    }
}
