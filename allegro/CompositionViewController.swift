//
//  CompositionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit



class CompositionViewController: UIViewController {
    
    var actionGestureRecognizer: AllegroGestureRecognizer?
    
    var debugGestureLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
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
        debugGestureLabel.frame = CGRect(x: 22, y: 22, width: 100, height: 16)
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
        actionGestureRecognizer = AllegroGestureRecognizer(view: view)
        actionGestureRecognizer?.delegate = self
        
        AllegroTweaks.bind(AllegroTweaks.actionDelta) { [weak self] value -> Void in
            self?.actionGestureRecognizer?.delta = value
        }
        AllegroTweaks.bind(AllegroTweaks.actionCost) { [weak self] (v: Int) -> Void in
            self?.actionGestureRecognizer?.costMax = v
        }
    }
}

extension CompositionViewController: AllegroGestureDelegate {
    func actionGestureRecognized(gesture: AllegroGesture, at location: CGPoint) {
        debugGestureLabel.text = gesture.rawValue
        Log.info?.message("Recognized \(gesture.rawValue) action at \(location)")
    }
}
