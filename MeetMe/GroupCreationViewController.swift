//
//  GroupCreationViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit

class GroupCreationViewController: UIViewController {

    @IBOutlet weak var groupPhoto: UIImageView!
    @IBOutlet weak var groupTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextField: UITextField!
    
    var delegate: UIViewController!
    var newGroup: Group = Group()
    
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
