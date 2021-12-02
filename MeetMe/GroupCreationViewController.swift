//
//  GroupCreationViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//
import UIKit
import Firebase

class GroupCreationViewController: UIViewController, addFriends {
    
    @IBOutlet weak var groupPhoto: UIImageView!
    @IBOutlet weak var groupTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextField: UITextField!
    
    var delegate: UIViewController!
    var newGroup: Group!
    var adminRun: Bool = true
    
    var members: [String] = []
    
    let db = Firestore.firestore()
    
    let addFriendsSegue = "AddFriendsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func adminRunSegCtrl(_ sender: Any) {
        switch groupTypeSegCtrl.selectedSegmentIndex {
        case 0:
            adminRun = true
        case 1:
            adminRun = false
        default:
            print("This shouldn't happen")
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func createButtonPressed(_ sender: Any) {
        let currentName:String = groupNameTextField.text!
        if !currentName.isEmpty {
            if Auth.auth().currentUser != nil {
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    // Create hash of the groups object
                    newGroup = Group()
                    var hasher = Hasher()
                    hasher.combine(newGroup.groupName)
                    hasher.combine(newGroup.groupDescr)
                    let hash = String(hasher.finalize())
                    // Create the instance object
                    members.append(uid)
                    let groupDb : [String: Any] = [
                        "uid": hash,
                        "name": currentName,
                        "admin": adminRun,
                        "creator": uid,
                        "description": groupDescriptionTextField.text!,
                        "peopleInGroup": members,
                        "events": []
                    ]
                    newGroup.groupName = currentName
                    newGroup.groupDescr = groupDescriptionTextField.text!
                    newGroup.groupHASH = hash
                    newGroup.groupCreator = uid
                    newGroup.members = members
                    newGroup.events = []
                    // Add it to the groups instance
                    self.db.collection("Groups").document(hash).setData(groupDb)
                    // Search for the user and append it to existing array
                    self.db.collection("Users").document(uid).updateData(["groupsAll": FieldValue.arrayUnion([hash])])
                    let otherVC = delegate as! GroupsPage
                    otherVC.addGroup(newGroup: newGroup)
                }
                
            } else {
              // No user is signed in.
              // ...
            }
        } else {
            let controller = UIAlertController(
                title: "Missing Name",
                message: "Please select add a name to the group.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil ))
            present(controller,
                    animated: true,
                    completion: nil)
        }
    }
    
    func addFriends(newUser: String) {
        members.append(newUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
           let destination = segue.destination as? GroupStackViewController {
//            destination.currGroupHASH = newGroup.groupHASH
//            destination.currGroupName = newGroup.groupName
            destination.currGroup = newGroup
            destination.loaded = true
        }
        if segue.identifier == addFriendsSegue,
            let destination = segue.destination as? FriendListViewController {
            destination.group = newGroup
            destination.delegate = self
            destination.loaded = true
            destination.fromSettings = false
        }
    }
}
