//
//  cellViewController.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class cellViewController: UITableViewCell {
    //Outlets
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var nombreContacto: UILabel!
    @IBOutlet weak var nombreChat: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
