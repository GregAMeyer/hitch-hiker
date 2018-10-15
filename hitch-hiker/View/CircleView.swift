//
//  CircleView.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/14/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    //allow diferent border colors per ibuilder
    @IBInspectable var borderColor: UIColor? {
        didSet {
            setupView()
        }
    }
    
    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderWidth = 1.5
        self.layer.borderColor = borderColor?.cgColor
    }

}
