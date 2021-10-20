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
    
    func validateFields() -> String? {
        // Check if all of them have an empty string
        validateName()
        validateUsername()
//        validatePassword()
        return nil
    }
    
    func validateName() {
        
    }
    
    func validateUsername(){
        
    }
    
    func validatePassword() -> Bool {
        return false
    }
    
    func validateLocation() {
        
    }
    
    func validatePhoneNumber() {
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        // Check fields
        // Create the new user
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          // ...
            print("Account: \(email)")
            print("Password: \(password)")
        }
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
