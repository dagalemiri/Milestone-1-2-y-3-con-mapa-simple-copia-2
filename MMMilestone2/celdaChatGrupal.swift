//
//  celdaChatGrupal.swift
//  MMMilestone2
//
//  Created by David Galemiri on 20-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class celdaChatGrupal: UITableViewCell {
    //Outlets
    @IBOutlet weak var numero: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var nombre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
}
