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

    fileprivate var measureView = MeasureView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        view.addSubview(measureView)
        view.addSubview(noteSelectorMenu)

    }

    override func viewDidLayoutSubviews() {
        // occupies the left side of the screen
        noteSelectorMenu.frame = CGRect(x: 0,
                                        y: 0,
                                        width: DEFAULT_TAP_TARGET_SIZE,
                                        height: view.bounds.height)

        // occupies space to the right of the menu
        measureView.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                                   y: 0,
                                   width: view.bounds.width - noteSelectorMenu.frame.width,
                                   height: view.bounds.height)
        measureView.thickness = 5.0
        measureView.distanceApart = 15.0
    }
}
