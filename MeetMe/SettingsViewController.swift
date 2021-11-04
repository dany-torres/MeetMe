//
//  SettingsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/16/21.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayPicture: UIImageView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                let userDb : [String: Any] = [
                    "name": nameTextField.text!,
                    "username": usernameTextField.text!,
                    "location": locationTextField.text!
                ]
                self.db.collection("Users").document(uid).updateData(userDb)
            }
            
            
        } else {
          // No user is signed in.
          // ...
        }
    }
    
    @IBAction func languageSegCtrl(_ sender: Any) {
    }
    
    @IBAction func modeSegCtrl(_ sender: Any) {
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                db.collection("Users").document(uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                        do {
                            try Auth.auth().signOut()
                            self.performSegue(withIdentifier: "BackToSignInSegue", sender: nil)
                        } catch let signOutError as NSError {
                          print("Error signing out: %@", signOutError)
                        }
                    }
                }
            }
            
            
        } else {
          // No user is signed in.
          // ...
        }
        
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "BackToSignInSegue", sender: nil)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
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
