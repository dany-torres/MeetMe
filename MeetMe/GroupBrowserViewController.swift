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
                                        print("Document does not exist")
                                    }
                                }
                            }
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
    }
    
    
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
