//
//  CenterVCDelegate.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/15/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit

protocol CenterVCDelegate {
    func toggleLeftPanel()
    func addLeftPanelViewController()
    func animateLeftPanel(shouldExpand: Bool)
}
