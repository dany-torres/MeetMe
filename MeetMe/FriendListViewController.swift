//
//  FriendListViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var usersList: [String] = []
    
    let db = Firestore.firestore()

    let UserCellIdentifier = "Cell"
    var delegate: UIViewController!
    var group: Group!
    var loaded: Bool = false
    var fromSettings = true
    var currentMembers: [String] = []
    
    var filteredData: [String]!

    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendSearchBar.delegate = self
        
        let queue = DispatchQueue(label: "curr")
        queue.async {
            while (!self.loaded){
                sleep(1)
            }
            self.populateFriendTable()
        }
        
        filteredData = usersList

    }
    
    // This method updates filteredData based on the text in the Search Box
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // When there is no text, filteredData is the same as the original data
            // When user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = searchText.isEmpty ? usersList : usersList.filter { (item: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            
            friendsTableView.reloadData()
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredData[indexPath.row]
        if fromSettings {
            db.collection("Groups").document(group.groupHASH).updateData(["peopleInGroup": FieldValue.arrayUnion([selectedUser])])
            db.collection("Users").document(selectedUser).updateData(["groupsAll": FieldValue.arrayUnion([group.groupHASH])])
        }
        currentMembers.append(selectedUser)
        filteredData = filteredData.filter {$0 != selectedUser}
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
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellIdentifier, for: indexPath) as! AddFriendTableViewCell
        let row = indexPath.row
        let user = filteredData[row]
        let friendRef = self.db.collection("Users").document(user)
        friendRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let friendsData = document.data()
                cell.nameLabel.text = friendsData!["name"] as? String
                cell.usernameLabel.text = "@" + (friendsData!["username"] as? String ?? "")
                self.setUserPicture(uid:friendsData!["uid"] as! String, cell:cell)
            } else {
                print("Friend does not exist")
            }
        }
        
        return cell
    }
    
    // Sets user picture within cell
    func setUserPicture(uid:String, cell:UITableViewCell){
        // Make image a circle
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.height)!/2
        cell.imageView?.clipsToBounds = true
        
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
}
