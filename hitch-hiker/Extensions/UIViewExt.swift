//
//  UIViewExt.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/18/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit
extension UIView {
    func fadeTo(alphaValue: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
}
