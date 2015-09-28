//
//  CeldaAgregarUsuarios.swift
//  MMMilestone2
//
//  Created by David Galemiri on 29-08-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class CeldaAgregarUsuarios: UITableViewCell {
    //Outlets
    @IBOutlet weak var nombre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    } 
}
