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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func inviteLinkButtonPressed(_ sender: Any) {
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
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
