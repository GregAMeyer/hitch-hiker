//
//  RoundImageView.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/14/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width/2
        self.clipsToBounds = true
    }

}
