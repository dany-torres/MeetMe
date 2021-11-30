//
//  StackTableViewCell.swift
//  MeetMe
//
//  Created by Daniela Torres on 11/3/21.
//
import UIKit
import Firebase



protocol MyStackCellDelegate: AnyObject {
    func didTapCellButton1(cell: StackTableViewCell)
    func didTapCellButton2(cell: StackTableViewCell)
    func didTapCellButton3(cell: StackTableViewCell)
}

class StackTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var event1: UILabel!
    @IBOutlet weak var event2: UILabel!
    @IBOutlet weak var event3: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    
    var eventOne:Event? = nil
    var eventTwo:Event? = nil
    var eventThree:[Event] = []
    
    weak var delegate : MyStackCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Add action to perform when the button is tapped
//        self.button1.addTarget(self, action: #selector(didTapCellButton1(_:)), for: .touchUpInside)

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapCellButton1(_ sender: Any) {
        delegate?.didTapCellButton1(cell: self)
    }
    
    @IBAction func didTapCellButton2(_ sender: Any) {
        delegate?.didTapCellButton2(cell: self)
    }
    
    @IBAction func didTapCellButton3(_ sender: Any) {
        delegate?.didTapCellButton3(cell: self)
    }
    
    
}
