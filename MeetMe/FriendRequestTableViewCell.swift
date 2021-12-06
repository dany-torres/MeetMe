//
//  FriendRequestTableViewCell.swift
//  MeetMe
//
//  Created by Pamela Vazquez De La Cruz on 11/30/21.
//

import UIKit
import Firebase

protocol FriendRequestCellDelegate: AnyObject {
    func didTapAcceptButton(cell: FriendRequestTableViewCell)
    func didTapDeclineButton(cell: FriendRequestTableViewCell)
}

class FriendRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    
    weak var delegate : FriendRequestCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapAcceptButton(_ sender: Any) {
        delegate?.didTapAcceptButton(cell: self)
    }
    
    @IBAction func didTapDeclineButton(_ sender: Any) {
        delegate?.didTapDeclineButton(cell: self)
    }
    
}
