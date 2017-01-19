//
//  SideMenuViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    private let MenuOptions: UIView = {
        let v = UILabel() // TODO(btc): replace this with the logo image
        v.text = Strings.APP_NAME
        v.textAlignment = .center
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 60)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        view.addSubview(MenuOptions)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)

    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped Right")
                _ = navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }

    

}
