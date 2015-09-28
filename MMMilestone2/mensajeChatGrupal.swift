//
//  mensajeChatGrupal.swift
//  MMMilestone2
//
//  Created by David Galemiri on 19-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class mensajeChatGrupal: UITableViewCell {

    @IBOutlet weak var mensaje: UILabel!
    @IBOutlet weak var enviadoPor: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
