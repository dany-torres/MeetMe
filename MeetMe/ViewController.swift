//
//  ViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/10/21.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var validLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NOTE: Used for testing logging in user
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//          print("Error signing out: %@", signOutError)
//        }
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil{
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                self.usernameTextField.text = nil
                self.passwordTextField.text = nil
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return validLogin
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = usernameTextField.text,
              let password = passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
            validLogin = false
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {
          user, error in
          if let error = error, user == nil {
            let alert = UIAlertController(
              title: "Sign in failed",
              message: error.localizedDescription,
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
          } else {
              self.validLogin = true
          }
        }
    }
}

