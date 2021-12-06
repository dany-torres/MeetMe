//
//  GroupSettingsViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/12/21.
//

import UIKit
import Firebase

protocol addFriends {
    func addFriends(newUser: String)
}

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addFriends {
    
    var group:Group!
    let addFriendsSegue = "AddFriendsSegue"
    let storage = Storage.storage().reference()
    
    var delegate: UIViewController!
    
    @IBOutlet weak var groupPicture: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextField: UITextField!
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var addFriendsButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        groupMembersTableView.layer.borderWidth = 0.5
        groupMembersTableView.layer.cornerRadius = 10
        groupMembersTableView.layer.borderColor = UIColor(red: 208/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        
        setTextFields()
        
        // Check if can edit group (Community Run)
        if !group.adminRun || (group.adminRun && group.groupCreator == Auth.auth().currentUser!.uid) {
            saveButton.isHidden = false
        } else {
            // Hide button
            saveButton.isHidden = true
            cameraButton.isHidden = true
            addFriendsButton.isHidden = true
            groupNameTextField.isUserInteractionEnabled = false
            groupDescriptionTextField.isUserInteractionEnabled = false
        }
        
        // Make image a circle
        groupPicture.layer.borderWidth = 1
        groupPicture.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        groupPicture.layer.cornerRadius = groupPicture.frame.height/2
        groupPicture.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let uid = group.groupHASH
                guard let urlString = UserDefaults.standard.value(forKey: uid) as? String,
                      let url = URL(string: urlString) else {
                          return
                      }
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.groupPicture.image = image
                    }
                })
                task.resume()
        
    }
    
    func setTextFields(){
        // TODO: set group picture
        groupNameTextField.text = group.groupName
        groupDescriptionTextField.text = group.groupDescr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
        let row = indexPath.row
        let uid = group.members[row]
        let docRef = db.collection("Users").document(uid)
        docRef.getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    cell.textLabel?.text = "@" + (data["username"] as? String ?? "")
                    self.setMemberPicture(uid: data["uid"] as! String, cell: cell)
                }
            }
        }
        
        // Format cell, add corners
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = false
        
        return cell
    }
    

    @IBAction func cameraButtonPressed(_ sender: Any) {
        // TODO: add this
        presentPhotoActionSheet()
    }
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        // TODO: do this, add friends to group
    }
    
    // Update Group object and event
    @IBAction func saveButtonPressed(_ sender: Any) {
        if checkNewInfo() {
            group.groupName = groupNameTextField.text!
            group.groupDescr = groupDescriptionTextField.text!
    
            // Update group name in group Events DB
            for event in group.events {
                let eventDB : [String: Any] = [
                    "groupName": groupNameTextField.text!
                ]
                self.db.collection("Events").document(event).updateData(eventDB)
            }
            
            // Update group in database
            let groupDB : [String: Any] = [
                "name": groupNameTextField.text!,
                "description": groupDescriptionTextField.text!
            ]
            self.db.collection("Groups").document(group.groupHASH).updateData(groupDB)
            
            let otherVC = delegate as! UpdateGroup
            otherVC.updateGroup(group:group)
        }
    }
    
    // Check if all required fields are set
    func checkNewInfo() -> Bool {
        if groupNameTextField.text! == "" {
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
            return false
        }
        return true
    }
    
    // Sets user picture within cell
    func setMemberPicture(uid:String, cell:UITableViewCell){
        // Make image a circle
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.height)!/2
        cell.imageView?.clipsToBounds = true
        
        guard let urlString = UserDefaults.standard.value(forKey: uid) as? String,
              let url = URL(string: urlString) else {
                  return
              }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                cell.imageView?.image = image
            }
        })
        task.resume()
    }
    
    func addFriends(newUser: String) {
        group.members.append(newUser)
        groupMembersTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if we are navigating to the group settings
        if segue.identifier == addFriendsSegue,
           let destination = segue.destination as? FriendListViewController {
            destination.delegate = self
            destination.group = group
            destination.loaded = true
            destination.currentMembers = group.members
        }
    }
}

extension GroupSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
                let uid = group.groupHASH
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
                            self.groupPicture.image = selectedImage
                        }
                        
                        print("URL String: \(urlString)")
                        UserDefaults.standard.set(urlString, forKey: uid)
                    })
                })
                self.groupPicture.image = selectedImage
        
        
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
