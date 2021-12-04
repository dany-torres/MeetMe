//
//  UserRequestTableViewCell.swift
//  MeetMe
//
//  Created by Alejandro Balderas Knoell on 11/29/21.
//

import UIKit
import Firebase

protocol UserRequestTableViewCellDelegate: AnyObject {
    func didTapButton(cell: UserRequestTableViewCell)
}

class UserRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    weak var delegate : UserRequestTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func didTapButton(_ sender: Any) {
        delegate?.didTapButton(cell: self)
    }
    
}
