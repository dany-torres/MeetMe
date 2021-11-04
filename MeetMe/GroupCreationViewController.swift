//
//  GroupCreationViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

class GroupCreationViewController: UIViewController {

    @IBOutlet weak var groupPhoto: UIImageView!
    @IBOutlet weak var groupTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextField: UITextField!
    
    var delegate: UIViewController!
    var newGroup: Group = Group()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func adminRunSegCtrl(_ sender: Any) {
        switch groupTypeSegCtrl.selectedSegmentIndex {
        case 0:
            newGroup.setAdminRun(setting: true)
        case 1:
            newGroup.setAdminRun(setting: false)
        default:
            print("This shouldn't happen")
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func inviteLinkButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        let currentName:String = groupNameTextField.text!
        if !currentName.isEmpty {
            newGroup.groupName = currentName
            newGroup.groupDescr = groupDescriptionTextField.text!
            let otherVC = delegate as! GroupsPage
            otherVC.addGroup(newGroup: newGroup)
            if Auth.auth().currentUser != nil {
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
//                    let nameRef = db.collection("Users").document(uid)
                    
//                    nameRef.getDocument { (document, error) in
//                        if let document = document, document.exists {
//                            let data = document.data()
//                            let name = data!["name"] as? String ?? ""
//
//                        } else {
//                            print("Document does not exist")
//                        }
//                    }
                    // Create hash of the groups object
                    var hasher = Hasher()
                    hasher.combine(newGroup.groupName)
                    hasher.combine(newGroup.groupDescr)
                    let hash = String(hasher.finalize())
                    // Create the instance object
                    let groupDb : [String: Any] = [
                        "uid": hash,
                        "name": newGroup.groupName,
                        "admin": true,
                        "whoCreated": uid,
                        "description": newGroup.groupDescr,
                        "inviteLink": "",
                        "peopleInGroup": [],
                        "events": []
                    ]
                    // Add it to the groups instance
                    self.db.collection("Groups").document(hash).setData(groupDb)
                    // Search for the user and append it to existing array
                    self.db.collection("Users").document(uid).updateData(["groupsAll": FieldValue.arrayUnion([hash])])
                    
                    
                    
                    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
