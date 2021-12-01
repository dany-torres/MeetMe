//
//  FriendRequestTableViewCell.swift
//  MeetMe
//
//  Created by Pamela Vazquez De La Cruz on 11/30/21.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {
    
    //TODO: add outlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
