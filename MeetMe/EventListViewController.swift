//
//  EventListViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 11/25/21.
//

import UIKit

class EventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var events:[Event] = []
    var delegate: UIViewController!
    
    @IBOutlet weak var eventTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = events[row].eventName
        // set image to creator's profile picture
        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetailsSegue",
           let destination = segue.destination as? EventDetailsViewController,
           let eventIndex = eventTableView.indexPathForSelectedRow?.row {
            destination.event = events[eventIndex]
        }
    }

}
