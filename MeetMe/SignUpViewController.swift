//
//  SignUpViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let db = Firestore.firestore()
    
    var bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // check if the password is strong by some standard
    func validatePassword() -> Bool {
            
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let secure = passwordTest.evaluate(with: cleanedPassword)
        
        if secure == false {
            // Password isn't secure enough
            // Must contain 8 characters a special character and a number
            print(false)
            return false
        }
        print(true)
        return true
    }
    
    // check if the phone number is valid
    func validatePhoneNumber() -> Bool {
        return false
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        // Check fields
        // Create the new user
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirm = confirmPasswordTextField.text,
              let name = nameTextField.text,
              let userName = usernameTextField.text,
              let location = locationTextField.text,
              email.count > 0,
              password.count > 0,
              name.count > 0,
              userName.count > 0,
              location.count > 0,
              password == confirm,
              validatePassword()
        else {
            return
        }
        
        db.collection("Users").whereField("username", isEqualTo: userName)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // Error finding user
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot!.documents.count == 0 {
                        // The username does not exist so we continue
                        print("Username: \(userName) does not exist")
                        Auth.auth().createUser(withEmail: email, password: password) { user, error in
                            if error == nil {
                                Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                                   password: self.passwordTextField.text!)
                                if Auth.auth().currentUser != nil {
                                    let user = Auth.auth().currentUser
                                    if let user = user {
                                        let uid = user.uid
                                        let userDb : [String: Any] = [
                                            "uid": uid,
                                            "name": name,
                                            "username": userName,
                                            "location": location,
                                            "language": false,
                                            "mode": false,
                                            "groupsAll": [],
                                            "groupsNotif": [],
                                            "groupsMuted": [],
                                            "events": []
                                        ]
                                        self.db.collection("Users").document(uid).setData(userDb)
                                    }
                                    
                                    
                                } else {
                                  // No user is signed in.
                                  // ...
                                }
                                self.shouldPerformSegue(withIdentifier: "signInSegue", sender: nil)
                            }
                        }
                    } else {
                        // The username exists so its invalid
                        print("Username: \(userName) EXISTS")
                    }
//                    }
                }
        }
        
        self.dismiss(animated: true, completion: nil)
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
