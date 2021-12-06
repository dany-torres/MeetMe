//
//  GroupBrowserViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

protocol GroupsPage {
    func addGroup(newGroup:Group)
}

class GroupBrowserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupsPage {
    
    var groups: [Group] = []
    
    let db = Firestore.firestore()

    let groupCellIdentifier = "Cell"
    let groupSegue = "GroupSegue"
    let newGroupSegue = "NewGroupSegue"
    
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
        rePopulateGroupsTable()
    }
    
    // Reload stack to show any event edits
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        if data["mode"] as? Bool ?? false == false {
                            // light
                            UIApplication.shared.windows.forEach { window in
                                window.overrideUserInterfaceStyle = .light
                            }
                            self.navigationController?.navigationBar.backgroundColor = UIColor.white
                            self.navigationController?.navigationBar.tintColor = UIColor.black
                        } else {
                            // dark
                            UIApplication.shared.windows.forEach { window in
                                window.overrideUserInterfaceStyle = .dark
                            }
                            self.navigationController?.navigationBar.backgroundColor = UIColor.black
                            self.navigationController?.navigationBar.tintColor = UIColor.white
                        }
                    }
                }
            }
        }
//            if false {
//                UIApplication.shared.windows.forEach { window in
//                    window.overrideUserInterfaceStyle = .light
//                }
//                self.navigationController?.navigationBar.backgroundColor = UIColor.white
//                self.navigationController?.navigationBar.tintColor = UIColor.black
//            } else {
//                UIApplication.shared.windows.forEach { window in
//                    window.overrideUserInterfaceStyle = .dark
//                }
//                self.navigationController?.navigationBar.backgroundColor = UIColor.black
//                self.navigationController?.navigationBar.tintColor = UIColor.white
//            }
        groupTableView.reloadData()
    }
    
    @IBAction func newGroupButtonPressed(_ sender: Any) {
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: groupCellIdentifier, for: indexPath) as! GroupsTableViewCell
        let row = indexPath.row
        let group = groups[row]
        cell.groupName.text = group.groupName
        cell.groupDescription.text = group.groupDescr
        //Choose pic from group
        // Make image a circle
        cell.groupImage.layer.borderWidth = 1
        cell.groupImage.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        cell.groupImage.layer.cornerRadius = cell.groupImage.frame.height/2
        cell.groupImage.clipsToBounds = true
        
        // Set Picture
        let uid = group.groupHASH
        setPicture(uid:uid, cell:cell)
        //if (currentUser.muted.contains(group.groupHASH){
        //      cell.mutedLabel.isHidden = false
        //}
        //if (currentUser.notification.contains(group.groupHASH){
        //      cell.notificationLabel.isHidden = false
        //}
        
//        cell.textLabel?.s = group.groupDescr         need to add subtitle
        return cell
    }
    
    func addGroup(newGroup: Group) {
        groups.append(newGroup)
        groupTableView.reloadData()
    }
    
    // Sets user picture within cell
    func setPicture(uid:String, cell:GroupsTableViewCell){
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
                cell.groupImage.image = image
            }
        })
        task.resume()
    }
    
    func rePopulateGroupsTable(){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                    let nameRef = db.collection("Users").document(uid)
                
                    nameRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let userGroups = data!["groupsAll"] as! [String]
                            
                            for group in userGroups {
                                let groupRef = self.db.collection("Groups").document(group)
                                
                                groupRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let groupsData = document.data()
                                        let currGroup = Group()
                                        currGroup.groupHASH = groupsData!["uid"] as! String
                                        currGroup.groupName = groupsData!["name"] as! String
                                        currGroup.groupDescr = groupsData!["description"] as! String
                                        currGroup.adminRun = groupsData!["admin"] as! Bool
                                        currGroup.groupCreator = groupsData!["creator"] as! String
                                        
                                        currGroup.members = groupsData!["peopleInGroup"] as! [String]
                                        currGroup.events = groupsData!["events"] as! [String]
                                        self.addGroup(newGroup: currGroup)
                                    } else {
                                        print("Group does not exist")
                                        // Delete group from db
                                        self.db.collection("Users").document(uid).updateData([
                                            "groupsAll": FieldValue.arrayRemove([group])
                                        ])
                                        self.db.collection("Groups").document(group).delete()
                                    }
                                }
                            }
                        } else {
                            print("User does not exist")
                        }
                    }
                }
            }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Create a variable that you want to send based on the destination view controller
//        // You can get a reference to the data by using indexPath shown below
//        let currGroup = groups[indexPath.row]
//
//        // Create an instance of PlayerTableViewController and pass the variable
//        let destination = GroupStackViewController()
//        destination.loaded = true
//        destination.currGroup = currGroup
//
//        // Let's assume that the segue name is called playerSegue
//        // This will perform the segue and pre-load the variable for you to use
//        destination.performSegue(withIdentifier: "GroupSegue", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == newGroupSegue,
           let destination = segue.destination as? GroupCreationViewController {
            destination.delegate = self
        }
        if segue.identifier == groupSegue,
           let destination = segue.destination as? GroupStackViewController {
           let groupIndex = groupTableView.indexPathForSelectedRow?.row
           let currGroup = groups[groupIndex!]
           destination.loaded = true
           destination.currGroup = currGroup
        }

    }
}

