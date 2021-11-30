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
    @IBOutlet weak var language: UISegmentedControl!
    @IBOutlet weak var mode: UISegmentedControl!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFields()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLanguage()
    }
    
    func setLanguage(){
        if Auth.auth().currentUser != nil {
            let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        if data["language"] as? Bool ?? false == false {
                            // english
                            self.language.selectedSegmentIndex = 0
                        } else {
                            // spanish
                            self.language.selectedSegmentIndex = 1
                        }
                    }
                }
            }
        }
    }
    
    func setTextFields(){
        if Auth.auth().currentUser != nil {
            let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        print("data", data)
                        self.nameTextField.text! = data["name"] as? String ?? ""
                        self.usernameLabel.text! = "@" + (data["username"] as? String ?? "")
                        self.usernameTextField.text! = data["username"] as? String ?? ""
                        self.locationTextField.text! = data["location"] as? String ?? ""
                    }
                }
            }
        }
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
        
        switch language.selectedSegmentIndex {
        case 0:
            // English
            let controller = UIAlertController(
                title: "Cambiando el lenguaje a Ingles",
                message: "Tienes que cerrar y volver a abrir la aplicacion para ver los cambios.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        self.language.selectedSegmentIndex = 1
                                    }
            ))
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        Bundle.setLanguage("en")
                                        UserDefaults.standard.set("en", forKey: "selectedLanguage")
                                        if Auth.auth().currentUser != nil {
                                            let user = Auth.auth().currentUser
                                            if let user = user {
                                                let uid = user.uid
                                                let userDb : [String: Any] = [
                                                    "language": false
                                                ]
                                                self.db.collection("Users").document(uid).updateData(userDb) { err in
                                                    if let err = err {
                                                        print("Error writing document: \(err)")
                                                    } else {
                                                        print("Document successfully written!")
                                                    }
                                                }
                                            }
                                            
                                            
                                        } else {
                                          // No user is signed in.
                                          // ...
                                        }
                                    }
            ))
            present(controller,
                    animated: true,
                    completion: nil)
        case 1:
            // Spanish
            let controller = UIAlertController(
                title: "Changing language to Spanish",
                message: "You have to close and open the app to make the changes.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        self.language.selectedSegmentIndex = 0
                                    }))
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        UserDefaults.standard.set("es", forKey: "selectedLanguage")
                                        Bundle.setLanguage("es")
                                        if Auth.auth().currentUser != nil {
                                            let user = Auth.auth().currentUser
                                            if let user = user {
                                                let uid = user.uid
                                                let userDb : [String: Any] = [
                                                    "language": true
                                                ]
                                                self.db.collection("Users").document(uid).updateData(userDb){ err in
                                                    if let err = err {
                                                        print("Error writing document: \(err)")
                                                    } else {
                                                        print("Document successfully written!")
                                                    }
                                                }
                                            }
                                            
                                            
                                        } else {
                                          // No user is signed in.
                                          // ...
                                        }
                                    }
            ))
            present(controller,
                    animated: true,
                    completion: nil)
        default:
            print("Error")
        }
//        exit(0)
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

//MARK: Localization configure bundle
extension Bundle {
    class func setLanguage(_ language: String) {
        var onceToken: Int = 0
        
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
private var associatedLanguageBundle:Character = "0"

class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))
    }
}
