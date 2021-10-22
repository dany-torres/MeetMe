//
//  GroupBrowserViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit

protocol GroupsPage {
    func addGroup(newGroup:Group)
}

class GroupBrowserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupsPage {
    
    var groups: [Group] = []

    let groupCellIdentifier = "Cell"
    let groupSegue = "GoupSegue"
    let newGroupSegue = "NewGroupSegue"
    
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
    }
    
    @IBAction func newGroupButtonPressed(_ sender: Any) {
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: groupCellIdentifier, for: indexPath)
        let row = indexPath.row
        let group = groups[row]
        cell.textLabel?.text = group.groupName
//        cell.textLabel?.s = group.groupDescr         need to add subtitle
        return cell
    }
    
    func addGroup(newGroup: Group) {
        groups.append(newGroup)
        groupTableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == newGroupSegue,
           let destination = segue.destination as? GroupCreationViewController {
            destination.delegate = self
        }
    }

}
