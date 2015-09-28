//
//  MostrarImagenGrupalViewController.swift
//  MMMilestone2
//
//  Created by David Galemiri on 07-09-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class MostrarImagenGrupalViewController: UIViewController {
    //Outlets y variables
    @IBOutlet weak var imageView: UIImageView!
    var url:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOfURL: url){
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.image = UIImage(data: data)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
