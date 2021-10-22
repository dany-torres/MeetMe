//
//  GroupStackViewController.swift
//  MeetMe
//
//  Created by Daniela Torres on 10/11/21.
//

import UIKit


protocol AddNewEvent {
    func addNewEvent(newEvent: Event)
}

class GroupStackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddNewEvent {
    public var eventList:[Event] = []
    var delegate: UITableView!
    
    @IBOutlet weak var eventStack: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change back button ot go to root rather than create group
        var viewControllersArray = [UIViewController]()
        viewControllersArray.append(self.navigationController!.viewControllers.first!)
        viewControllersArray.append(self.navigationController!.viewControllers.last!)
        self.navigationController?.setViewControllers(viewControllersArray, animated: false)
        
        eventStack.delegate = self
        eventStack.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stackCell", for: indexPath)
        
        //After creating the cell, update the properties of the cell with appropriate data values.
        let row = indexPath.row
        cell.textLabel?.text = eventList[row].printEventDetails()
        return cell
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "CreateEventSegue",
            let nextVC = segue.destination as? CreateEventViewController {
             nextVC.delegate = self
         
         }
     }
    
    func addNewEvent(newEvent: Event) {
            eventList.append(newEvent)
            eventStack.reloadData()
        }
         
}
