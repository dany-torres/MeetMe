//
//  GroupCreationViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//
import UIKit
import Firebase

class GroupCreationViewController: UIViewController, addFriends {
    
    @IBOutlet weak var groupPhoto: UIImageView!
    @IBOutlet weak var groupTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextField: UITextField!
    
    var delegate: UIViewController!
    var newGroup: Group!
    var adminRun: Bool = true
    
    var members: [String] = []
    var hashGroup: String = ""
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    let addFriendsSegue = "AddFriendsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make image a circle
        groupPhoto.layer.borderWidth = 1
        groupPhoto.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        groupPhoto.layer.cornerRadius = groupPhoto.frame.height/2
        groupPhoto.clipsToBounds = true
        // Do any additional setup after loading the view.
        hashGroup = randomString(length: 15)
        print(hashGroup)
    }
    
    @IBAction func adminRunSegCtrl(_ sender: Any) {
        switch groupTypeSegCtrl.selectedSegmentIndex {
        case 0:
            adminRun = true
        case 1:
            adminRun = false
        default:
            print("This shouldn't happen")
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        presentPhotoActionSheet()
    }
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func createButtonPressed(_ sender: Any) {
        let currentName:String = groupNameTextField.text!
        if !currentName.isEmpty {
            if Auth.auth().currentUser != nil {
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    // Create hash of the groups object
                    newGroup = Group()
                    // Create the instance object
                    members.append(uid)
                    let groupDb : [String: Any] = [
                        "uid": hashGroup,
                        "name": currentName,
                        "admin": adminRun,
                        "creator": uid,
                        "description": groupDescriptionTextField.text!,
                        "peopleInGroup": members,
                        "events": []
                    ]
                    newGroup.groupName = currentName
                    newGroup.groupDescr = groupDescriptionTextField.text!
                    newGroup.groupHASH = hashGroup
                    newGroup.groupCreator = uid
                    newGroup.members = members
                    newGroup.events = []
                    // Add it to the groups instance
                    self.db.collection("Groups").document(hashGroup).setData(groupDb)
                    // Search for the user and append it to existing array
                    self.db.collection("Users").document(uid).updateData(["groupsAll": FieldValue.arrayUnion([hashGroup])])
                    let otherVC = delegate as! GroupsPage
                    otherVC.addGroup(newGroup: newGroup)
                }
                
            } else {
              // No user is signed in.
              // ...
            }
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
    
    func addFriends(newUser: String) {
        members.append(newUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
           let destination = segue.destination as? GroupStackViewController {
//            destination.currGroupHASH = newGroup.groupHASH
//            destination.currGroupName = newGroup.groupName
            destination.currGroup = newGroup
            destination.loaded = true
        }
        if segue.identifier == addFriendsSegue,
            let destination = segue.destination as? FriendListViewController {
            destination.group = newGroup
            destination.delegate = self
            destination.loaded = true
            destination.fromSettings = false
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension GroupCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Group Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
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
        
        guard let imageData = selectedImage.pngData() else {
            return
        }
        
                let uid = hashGroup
                storage.child("groups/\(uid).png").putData(imageData, metadata: nil, completion: { _, error in
                    guard error == nil else {
                        print("failed to upload")
                        return
                    }
                    self.storage.child("groups/\(uid).png").downloadURL(completion: {url, error in
                        guard let url = url, error == nil else {
                            return
                        }
                        let urlString = url.absoluteString
                        
                        DispatchQueue.main.async {
                            self.groupPhoto.image = selectedImage
                        }
                        
                        print("URL String: \(urlString)")
                        UserDefaults.standard.set(urlString, forKey: uid)
                    })
                })
                self.groupPhoto.image = selectedImage
        
        
//        self.displayPicture.layer.masksToBounds = true
//        self.displayPicture.layer.cornerRadius = self.displayPicture.frame.size.width / 2.0
//        self.displayPicture.clipsToBounds = true
//        self.displayPicture.layer.borderWidth = 2.0
//        self.displayPicture.layer.borderColor = UIColor.purple.cgColor
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
