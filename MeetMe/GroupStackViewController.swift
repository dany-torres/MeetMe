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
    
    @IBOutlet weak var eventStack: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    public var eventList:[Event] = []
    var delegate: UITableView!
    var halfHours:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change back button ot go to root rather than create group
        var viewControllersArray = [UIViewController]()
        viewControllersArray.append(self.navigationController!.viewControllers.first!)
        viewControllersArray.append(self.navigationController!.viewControllers.last!)
        self.navigationController?.setViewControllers(viewControllersArray, animated: false)
        
        eventStack.delegate = self
        eventStack.dataSource = self
        
        setDayLabel()
        
        initTime()
        setTimeLabels()
    }
    
    // Initialize the halfHours array
    func initTime(){
        let possibleHours = ["00", "30"];
        for i in 0...24 {
            for item in possibleHours{
                halfHours.append(String(i) + ":" + item);
            }
        }
    }
    
    func setTimeLabels(){
        
    }
    
    // Sets the dat label to the current day
    func setDayLabel(){
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let month = Calendar.current.component(.month, from: today)
        let year =
        Calendar.current.component(.year, from: today)
        let date = Calendar.current.component(.day, from: today)

        let weekdayText = Calendar.current.shortWeekdaySymbols[weekday-1]
        let monthText = "\(Calendar.current.shortMonthSymbols[month-1]) \(date)"
        
        dateLabel.text = "\(weekdayText) \(monthText), \(year)"
        eventStack.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        eventList.count
        return halfHours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stackCell", for: indexPath) as! StackTableViewCell
        let row = indexPath.row
        let time = halfHours[row]
        cell.time.text = time
        
        
//        let event = eventList[row]
//        let time = halfHours[row]
//        cell.time.text = time
//        cell.eventLabel.text = event.eventName
//        cell.textLabel?.text = eventList[row].printEventDetails()
        return cell
    }
    
    func setEvents(_ cell: StackTableViewCell, _ events:[Event]){
        
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "CreateEventSegue",
            let nextVC = segue.destination as? CreateEventViewController {
             nextVC.delegate = self
//             TODO: PASS THE HASH AND THE NAME OF THE GROUP SEGUE
//             nextVC.hashGroup =
//             nextVC.nameGroup =
         
         }
     }
    
    func addNewEvent(newEvent: Event) {
            eventList.append(newEvent)
            eventStack.reloadData()
        }
         
}
