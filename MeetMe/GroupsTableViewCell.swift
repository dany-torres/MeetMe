//
//  GroupsTableViewCell.swift
//  MeetMe
//
//  Created by Alejandro Balderas Knoell on 11/3/21.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupDescription: UILabel!
    @IBOutlet weak var muteLabel: UIImageView!
    @IBOutlet weak var notificationLabel: UIImageView!
    @IBOutlet weak var groupImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
