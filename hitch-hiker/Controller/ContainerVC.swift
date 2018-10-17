//
//  ContainerVC.swift
//  hitch-hiker
//
//  Created by Gregory Meyer on 10/15/18.
//  Copyright © 2018 Gregory Meyer. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case collapsed
    case leftPanelExpanded
}

enum ShowWhichVC {
    case homeVC
}

var showVC: ShowWhichVC = .homeVC

class ContainerVC: UIViewController {
    
    var homeVC: HomeVC!
    var leftVC: LeftSidePanelVC!
    var centerController: UIViewController!
    var currentState: SlideOutState = .collapsed {
        didSet { //if changed, shadow can be modified too
            let shouldShowShadow = (currentState != .collapsed)
            shouldShowShadowForCenterViewController(status: shouldShowShadow)
        }
    }
    
    var isStatusBarHidden = false
    let centerPanelExpandedOffset: CGFloat = 160
    
    var tapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initCenter(screen: showVC)
    }
    
    func initCenter(screen: ShowWhichVC) {
        //when we initialize a new center, we remove everything in centerController before
        //we pass in a new viewController
        //a way to make sure were not passing in mult instance of same or diff VC
        //clear everything out and add a new one to make sure we dont take up too much memory
        var presentingController: UIViewController
        
        showVC = screen
        
        if homeVC == nil {
            homeVC = UIStoryboard.homeVC()
            homeVC.delegate = self
        }
        
        presentingController = homeVC
        
        if let con = centerController {
            con.view.removeFromSuperview()
            con.removeFromParent()
        }
        
        centerController = presentingController
        
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    //how to know whether it opens or closes
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }

}

extension ContainerVC: CenterVCDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if leftVC == nil {
            leftVC = UIStoryboard.leftViewController()
            addChildSidePanelViewController(leftVC!)
        }
    }
    
    func addChildSidePanelViewController(_ sidePanelController: LeftSidePanelVC) {
        view.insertSubview(sidePanelController.view, at: 0)
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    @objc func animateLeftPanel(shouldExpand: Bool) {
        isStatusBarHidden = !isStatusBarHidden
        animateStatusBar()
        if shouldExpand {
            setupWhiteCoverView()
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(targetPosition: centerController.view.frame.width - centerPanelExpandedOffset)
        }
        else {
            hideWhiteCoverView()
            animateCenterPanelXPosition(targetPosition: 0, completion: {
            (finished) in
                if finished == true {
                    self.currentState = .collapsed
                    self.leftVC = nil
                }
            })
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.centerController.view.frame.origin.x = targetPosition
                       },
                       completion: completion)
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.setNeedsStatusBarAppearanceUpdate()
                       })
    }
    
    func setupWhiteCoverView() {
        let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: view.frame.width,
                                                  height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = UIColor.white
        whiteCoverView.tag = 25
        
        self.centerController.view.addSubview(whiteCoverView)
        UIView.animate(withDuration: 0.2) {
            whiteCoverView.alpha = 0.75
        }
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(animateLeftPanel(shouldExpand:)))
        self.centerController.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func hideWhiteCoverView() {
        centerController.view.removeGestureRecognizer(tapGestureRecognizer)
        for subview in self.centerController.view.subviews {
            if subview.tag == 25 {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }, completion: { (finished) in
                    subview.removeFromSuperview()
                })
            }
        }
    }
    
    func shouldShowShadowForCenterViewController(status: Bool) {
        if status == true {
            centerController.view.layer.shadowOpacity = 0.6
        }
        else {
            centerController.view.layer.shadowOpacity = 0.0
        }
    }
}

//make it so this can instaitate and access all different view contorllers
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func leftViewController() -> LeftSidePanelVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftSidePanelVC") as? LeftSidePanelVC
    }
    
    class func homeVC() -> HomeVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
    }
}
