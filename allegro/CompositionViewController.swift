//
//  CompositionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit



class CompositionViewController: UIViewController {

    fileprivate var noteSelectorMenu: UIView = {
        let v = NoteSelectorMenu()
        return v
    }()

    fileprivate var store: PartStore?

    fileprivate var editor: PartEditor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        let p = Part()
        store = PartStore(part: p)
        guard let store = store else { return }

        editor = PartEditor(store: store)
        guard let editor = editor else { return }

        view.addSubview(editor)
        view.addSubview(noteSelectorMenu)

        let swipeLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.edges = .right
        self.view.addGestureRecognizer(swipeLeft)
    }

    override func viewDidLayoutSubviews() {
        // occupies the left side of the screen
        noteSelectorMenu.frame = CGRect(x: 0,
                                        y: 0,
                                        width: DEFAULT_TAP_TARGET_SIZE,
                                        height: view.bounds.height)

        // occupies space to the right of the menu
        editor?.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                                  y: 0,
                                  width: view.bounds.width - noteSelectorMenu.frame.width,
                                  height: view.bounds.height)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let g = gesture as? UIScreenEdgePanGestureRecognizer {
            
            switch g.edges {
            case UIRectEdge.right:
                print("Swiped left")
                let vc = SideMenuViewController()
                navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
}
