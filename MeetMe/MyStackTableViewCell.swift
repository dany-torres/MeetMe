//
//  MyStackTableViewCell.swift
//  MeetMe
//
//  Created by Daniela Torres on 12/6/21.
//

import UIKit

protocol MyStackDelegate: AnyObject {
    func didTapCellButton1MyStack(cell: MyStackTableViewCell)
    func didTapCellButton2MyStack(cell: MyStackTableViewCell)
    func didTapCellButton3MyStack(cell: MyStackTableViewCell)
}

class MyStackTableViewCell: UITableViewCell {
    
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
    
    weak var delegate : MyStackDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button1.isHidden = true
        button2.isHidden = true
        button3.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTapCellButton1MyStack(_ sender: Any) {
        delegate?.didTapCellButton1MyStack(cell: self)
    }
    
    @IBAction func didTapCellButton2MyStack(_ sender: Any) {
        delegate?.didTapCellButton2MyStack(cell: self)
    }
    
    @IBAction func didTapCellButton3MyStack(_ sender: Any) {
        delegate?.didTapCellButton3MyStack(cell: self)
    }
}
