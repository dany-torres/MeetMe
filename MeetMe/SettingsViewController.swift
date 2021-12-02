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
        self.displayPicture.layer.masksToBounds = true
        self.displayPicture.layer.cornerRadius = self.displayPicture.frame.size.width / 2.0
        self.displayPicture.clipsToBounds = true
        self.displayPicture.layer.borderWidth = 2.0
        self.displayPicture.layer.borderColor = UIColor.purple.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLanguage()
        setDarkMode()
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
    
    func setDarkMode(){
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
                        if data["mode"] as? Bool ?? false == false {
                            // light
                            self.mode.selectedSegmentIndex = 0
                        } else {
                            // dark
                            self.mode.selectedSegmentIndex = 1
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
        presentPhotoActionSheet()
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
    }
    
    @IBAction func modeSegCtrl(_ sender: Any) {
        switch mode.selectedSegmentIndex {
        case 0:
            // Light
            let controller = UIAlertController(
                title: "Changing to light mode",
                message: "You can revert the changes by pressing cancel.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        self.mode.selectedSegmentIndex = 1
                                    }
            ))
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        if Auth.auth().currentUser != nil {
                                            let user = Auth.auth().currentUser
                                            if let user = user {
                                                let uid = user.uid
                                                let userDb : [String: Any] = [
                                                    "mode": false
                                                ]
                                                self.db.collection("Users").document(uid).updateData(userDb) { err in
                                                    if let err = err {
                                                        print("Error writing document: \(err)")
                                                    } else {
                                                        print("Document successfully written!")
                                                        UIApplication.shared.windows.forEach { window in
                                                            window.overrideUserInterfaceStyle = .light
                                                        }
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
            // Dark
            let controller = UIAlertController(
                title: "Changing to dark mode",
                message: "You can revert the changes by pressing cancel.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        self.mode.selectedSegmentIndex = 0
                                    }))
            controller.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: {
                                        (paramAction:UIAlertAction!) in
                                        if Auth.auth().currentUser != nil {
                                            let user = Auth.auth().currentUser
                                            if let user = user {
                                                let uid = user.uid
                                                let userDb : [String: Any] = [
                                                    "mode": true
                                                ]
                                                self.db.collection("Users").document(uid).updateData(userDb){ err in
                                                    if let err = err {
                                                        print("Error writing document: \(err)")
                                                    } else {
                                                        print("Document successfully written!")
                                                        UIApplication.shared.windows.forEach { window in
                                                            window.overrideUserInterfaceStyle = .dark
                                                        }
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
    }
    
//    if false {
//        UIApplication.shared.windows.forEach { window in
//            window.overrideUserInterfaceStyle = .light
//        }
//        self.navigationController?.navigationBar.backgroundColor = UIColor.white
//        self.navigationController?.navigationBar.tintColor = UIColor.black
//    } else {
//        UIApplication.shared.windows.forEach { window in
//            window.overrideUserInterfaceStyle = .dark
//        }
//        self.navigationController?.navigationBar.backgroundColor = UIColor.black
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                
                let nameRef = db.collection("Users").document(uid)
                nameRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let userGroups = data!["groupsAll"] as! [String]
                        let userEvents = data!["events"] as! [String]
                        let userFriends = data!["friends"] as! [String]
                        
                        for event in userEvents {
                            let eventRef = self.db.collection("Events").document(event)
                            
                            eventRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let eventData = document.data()
                                    let newEvent = Event(eventName: eventData!["name"] as! String,
                                                         eventDate: eventData!["eventDate"] as! String,
                                                         startTime: eventData!["startTime"] as! String,
                                                         endTime: eventData!["endTime"] as! String,
                                                         location: eventData!["location"] as! String,
                                                         notifications: eventData!["notifications"] as! Bool,
                                                         reminderChoice: eventData!["reminderChoice"] as! String,
                                                         polls: eventData!["polls"] as! Bool,
                                                         messages: eventData!["messages"] as! Bool,
                                                         editEvents: eventData!["editable"] as! Bool,
                                                         eventCreator: eventData!["creator"] as! String,
                                                         nameOfGroup: eventData!["groupName"] as! String,
                                                         listOfAttendees: eventData!["attendees"] as! [String],
                                                         eventHash: eventData!["uid"] as! String,
                                                         groupHash: eventData!["groupHash"] as! String,
                                                         eventColor: eventData!["eventColor"] as! [Int]
                                    )
                                    //delete event from all user accepted
                                    self.deleteEventFromUsers(newEvent: newEvent)
                                    //delete event from groups
                                    self.deleteEventFromGroups(newEvent: newEvent)
                                    //delete event from events
                                    self.db.collection("Events").document(event).delete()
                                } else {
                                    print("Group does not exist")
                                }
                            }
                        }
                        
                        for group in userGroups {
                            let groupRef = self.db.collection("Groups").document(group)
                            
                            groupRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let groupsData = document.data()
                                    let currGroup = Group()
                                    currGroup.groupHASH = groupsData!["uid"] as! String
                                    currGroup.groupName = groupsData!["name"] as! String
                                    currGroup.groupDescr = groupsData!["description"] as! String
                                    currGroup.adminRun = groupsData!["admin"] as! Bool
                                    currGroup.groupCreator = groupsData!["creator"] as! String
                                    currGroup.members = groupsData!["peopleInGroup"] as! [String]
                                    currGroup.events = groupsData!["events"] as! [String]
                                    
                                    
                                    //delete group if User is admin
                                    if currGroup.adminRun {
                                        self.deleteAdminGroupFromUsers(newGroup: currGroup)
                                        self.db.collection("Groups").document(group).delete()
                                    } else {
                                        //delete user from group members
                                        self.deleteUserFromGroup(newGroup: currGroup, uid: uid)
                                    }
                                } else {
                                    print("Group does not exist")
                                }
                            }
                        }
                        
                        for friend in userFriends {
                            let friendRef = self.db.collection("Users").document(friend)
                            
                            friendRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let friendsData = document.data()
                                    
                                    let friendsList = friendsData!["friends"] as! [String]
                                    let newFriendsList = friendsList.filter {$0 != uid}
                                    self.db.collection("Users").document(friend).updateData(["friends": newFriendsList])
                                } else {
                                    print("Friend does not exist")
                                }
                            }
                        }
                        
                    } else {
                        print("User does not exist")
                    }
                }
                
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
            
            // delete User from AUTH
            user?.delete {error in
                if let error = error {
                    print("User wasnt deleted from AUTH \(error)")
                } else {
                    print("User deleted from Auth")
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
    
    func deleteAdminGroupFromUsers(newGroup: Group){
        for member in newGroup.members{
            let nameRef = db.collection("Users").document(member)
            nameRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let groups = data!["groupsAll"] as! [String]
                    let newGroups = groups.filter {$0 != newGroup.groupHASH}
                    self.db.collection("Users").document(member).updateData(["groupsAll": newGroups])
                }
            }
        }
    }
    
    func deleteUserFromGroup(newGroup: Group, uid: String){
        let nameRef = db.collection("Groups").document(newGroup.groupHASH)
        nameRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let members = data!["peopleInGroup"] as! [String]
                let newMembers = members.filter {$0 != uid}
                if newMembers.isEmpty{
                    self.db.collection("Groups").document(newGroup.groupHASH).delete()
                } else{
                    self.db.collection("Groups").document(newGroup.groupHASH).updateData(["peopleInGroup": newMembers])
                }
            }
        }
    }
    
    func deleteEventFromUsers(newEvent: Event){
        for attendees in newEvent.listOfAttendees{
            let nameRef = db.collection("Users").document(attendees)
            nameRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let eventsAttending = data!["events"] as! [String]
                    let newEvents = eventsAttending.filter {$0 != newEvent.eventHash}
                    self.db.collection("Users").document(attendees).updateData(["events": newEvents])
                }
            }
        }
    }
    
    func deleteEventFromGroups(newEvent: Event){
        let nameRef = db.collection("Groups").document(newEvent.groupHash)
        nameRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let events = data!["events"] as! [String]
                let newEvents = events.filter {$0 != newEvent.eventHash}
                self.db.collection("Groups").document(newEvent.groupHash).updateData(["events": newEvents])
            }
        }
    }
    
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

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.displayPicture.image = selectedImage
        self.displayPicture.layer.masksToBounds = true
        self.displayPicture.layer.cornerRadius = self.displayPicture.frame.size.width / 2.0
        self.displayPicture.clipsToBounds = true
        self.displayPicture.layer.borderWidth = 2.0
        self.displayPicture.layer.borderColor = UIColor.purple.cgColor
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
