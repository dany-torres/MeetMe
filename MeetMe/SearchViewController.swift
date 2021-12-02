//
//  SearchViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var usersList: [User] = []
    
    let db = Firestore.firestore()

    let UserCellIdentifier = "UserCell"

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = usersList[indexPath.row]
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                //Cambiar a FriendRequests para tener al interface
                db.collection("Users").document(selectedUser.hash).updateData(["friends": FieldValue.arrayUnion([uid])])
                db.collection("Users").document(uid).updateData(["friends": FieldValue.arrayUnion([selectedUser.hash])])
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellIdentifier, for: indexPath) as! UserRequestTableViewCell
        let row = indexPath.row
        let user = usersList[row]
        cell.nameLabel.text = user.name
        cell.usernameLabel.text = user.username
        return cell
    }
}
