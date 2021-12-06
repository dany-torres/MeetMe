//
//  EventListViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 11/25/21.
//

import UIKit

class EventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var events:[Event] = []
    var currGroup: Group!
    var cell:StackTableViewCell!
    
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

        // Make image a circle
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor(red: 166/255, green: 109/255, blue: 237/255, alpha: 1).cgColor
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.height)!/2
        cell.imageView?.clipsToBounds = true
        
        // Set Picture
        let uid = events[row].eventCreator
        let urlString = UserDefaults.standard.value(forKey: uid) as? String
        if urlString != nil {
            let url = URL(string: urlString!)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { data, _, error in
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
        
        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetailsSegue",
           let destination = segue.destination as? EventDetailsViewController,
           let eventIndex = eventTableView.indexPathForSelectedRow?.row {
            destination.event = events[eventIndex]
            destination.currGroup = currGroup
            destination.delegate = self
            destination.cell = cell
            destination.eventBlockNum = 4
        }
    }

}
