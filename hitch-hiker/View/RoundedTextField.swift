//
//  RoundedTextField.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/24/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {
    
    var textRectOffset: CGFloat = 20
    
    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    func getRectForTextField() -> CGRect {
        return CGRect(x: 0 + textRectOffset,
                      y: 0 + (textRectOffset/2),
                      width: self.frame.width - textRectOffset,
                      height: self.frame.height + textRectOffset)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return getRectForTextField()
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return getRectForTextField()
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0 + textRectOffset,
                     y: 0,// + (textRectOffset/2),
                     width: self.frame.width - textRectOffset,
                     height: self.frame.height)// + textRectOffset)
    }

}

//found on stackoverflow for adding padding to text fields
//going to use the videos way instead, but this can stay for future reference
//would call in setupView:
//        self.setLeftPaddingPoints(10)
//        self.setRightPaddingPoints(10)
//extension UITextField {
//    func setLeftPaddingPoints(_ amount:CGFloat){
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//    func setRightPaddingPoints(_ amount:CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.rightView = paddingView
//        self.rightViewMode = .always
//    }
//}
