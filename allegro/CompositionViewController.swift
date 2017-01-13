//
//  CompositionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit



class CompositionViewController: UIViewController {
    
    var actionGestureRecognizer: ActionGestureRecognizer?
    
    fileprivate var debugGestureLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 24)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupActionGestureRecognizer()

        if DEBUG {
            view.addSubview(debugGestureLabel)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        debugGestureLabel.frame = CGRect(x: 22, y: 22, width: 200, height: 24)
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
