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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // check if all the fields are valid
    func validateFields() -> Bool {
        // Check if all of them have an empty string
        return validateUsername() && validatePassword() && validatePhoneNumber()
    }
    
    // check if the username is unique
    func validateUsername() -> Bool {
        return false
    }
    
    // check if the password is strong by some standard
    func validatePassword() -> Bool {
        return false
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
              let user = usernameTextField.text,
              let location = locationTextField.text,
              email.count > 0,
              password.count > 0,
              name.count > 0,
              user.count > 0,
              location.count > 0,
              password == confirm
        else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                   password: self.passwordTextField.text!)
                self.shouldPerformSegue(withIdentifier: "signInSegue", sender: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
        // Populate the fields
        // Go to the homescreen
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
