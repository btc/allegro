//
//  CompositionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit



class CompositionViewController: UIViewController {
    
    fileprivate var actionGestureRecognizer: ActionGestureRecognizer?

    fileprivate var noteSelectorMenu: UIView = {
        let v = NoteSelectorMenu()
        return v
    }()

    fileprivate var debugGestureLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 24)
        return v
    }()
    
    fileprivate var measureView = MeasureView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        // TODO(btc): move this into the measure view
        setupActionGestureRecognizer()

        if DEBUG {
            view.addSubview(debugGestureLabel)
        }

        view.addSubview(measureView)
        view.addSubview(noteSelectorMenu)

    }

    override func viewDidLayoutSubviews() {
        // occupies the left side of the screen
        noteSelectorMenu.frame = CGRect(x: 0,
                                        y: 0,
                                        width: DEFAULT_TAP_TARGET_SIZE,
                                        height: view.bounds.height)

        // show at the top of the screen, to the right of the menu
        debugGestureLabel.frame = CGRect(x: noteSelectorMenu.frame.maxX + DEFAULT_MARGIN_PTS,
                                         y: 0,
                                         width: 200,
                                         height: 24)

        // occupies space to the right of the menu
        measureView.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                                   y: 0,
                                   width: view.bounds.width - noteSelectorMenu.frame.width,
                                   height: view.bounds.height)
        measureView.thickness = 5.0
        measureView.distanceApart = 15.0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionGestureRecognizer?.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionGestureRecognizer?.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionGestureRecognizer?.touchesEnded(touches, with: event)
    }
    
    private func setupActionGestureRecognizer() {
        actionGestureRecognizer = ActionGestureRecognizer(view: view)
        actionGestureRecognizer?.delegate = self
        
        Tweaks.bind(Tweaks.actionDelta) { [weak self] (v: Double) -> Void in
            self?.actionGestureRecognizer?.delta = v
        }
        Tweaks.bind(Tweaks.actionCost) { [weak self] (v: Int) -> Void in
            self?.actionGestureRecognizer?.costMax = v
        }
    }
}

extension CompositionViewController: ActionGestureDelegate {
    func actionGestureRecognized(gesture: ActionGesture, at location: CGPoint) {
        debugGestureLabel.text = gesture.rawValue
        Log.info?.message("Recognized \(gesture.rawValue) action at \(location)")
    }
}
