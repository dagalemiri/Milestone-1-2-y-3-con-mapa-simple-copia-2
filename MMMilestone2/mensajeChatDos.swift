//
//  mensajeChatDos.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class mensajeChatDos: UITableViewCell {
    //Outlets
    @IBOutlet weak var mensaje: UILabel!
    @IBOutlet weak var  enviadoPor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

