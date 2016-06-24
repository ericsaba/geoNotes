//
//  CustomTableViewCell.swift
//  Notes
//
//  Created by Eric Saba on 1/15/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet var textView: UITextView?
    @IBOutlet var directionLabel: UILabel?
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    func loadItem(text: String, distance: String, direction: String, image: UIImage, username: String) {
        textView?.text = text
        directionLabel?.text = direction
        distanceLabel.text = distance
        usernameLabel.text = username
        iconImageView.image = image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView?.selectable = false
        textView?.editable = false
        iconImageView.contentMode = .ScaleAspectFit
        iconImageView.layer.cornerRadius = 5.0
        iconImageView.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
