//
//  GradientView.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/10/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

class GradientView: UIView {

    let gradient = CAGradientLayer()
    
    //runs after everything loads from interface builder
    //use to display view changes
    override func awakeFromNib() {
        print("awakeFromNib")
        setupGradientView()
    }
    

    func setupGradientView() {
        //tell the gradient where it should live
        //it is a layer that will be placed on top of a UIView
        //so it should be the same size of the UIView it is on top of
        print("setting up gradient")
        gradient.frame = self.bounds
        print("gradient.frame", gradient.frame)
        print("self.bounds", self.bounds)
        print("self.bounds.size", self.bounds.size)
        print("self.bounds.size.width", self.bounds.size.width)
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.init(white: 1.0, alpha: 0.0).cgColor
        ]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        //which color goes where (from the .colors array)
        gradient.locations = [0.55, 1.0]
        //add it as a sublayer to the UIView so it shows up
        self.layer.addSublayer(gradient)
    }

}
