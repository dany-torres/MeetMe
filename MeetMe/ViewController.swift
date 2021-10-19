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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            print("Account: \(email)")
            print("Password: \(password)")
          // ...
        }
    }
    
    
}

