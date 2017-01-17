//
//  RootNavigationViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController {
    
    // |ipr| keep the the swipe to pop gesture enabled even while bar is hidden
    private var ipr: InteractivePopRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: true)
        
        ipr = InteractivePopRecognizer(self)
        interactivePopGestureRecognizer?.delegate = ipr
        interactivePopGestureRecognizer?.delaysTouchesBegan = false
    }
    
    private class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {
        weak var navigationController: UINavigationController?
        
        init(_ controller: UINavigationController) {
            self.navigationController = controller
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let nc = navigationController else { return false }
            return nc.viewControllers.count > 1
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
