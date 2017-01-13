//
//  AllegroGestureRecognizer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

// TODO(btc): move this somewhere appropriate
enum AllegroGesture: String {
    case note // tap
    case flat
    case sharp
    case natural
    case rest
    case dot // TODO(btc): double tap?
    case doubleDot // TODO(btc): triple tap?
    case chord // TODO(btc): should we include this at all?
}

protocol AllegroGestureDelegate: class {
    func actionGestureRecognized(gesture: AllegroGesture, at location: CGPoint)
}

class AllegroGestureRecognizer {
    static let SWIPE_MOVEMENT_DISTANCE: Double = 22
    private let swipeGestureRecognizer = DBPathRecognizer(sliceCount: 8,
                                                          deltaMove: SWIPE_MOVEMENT_DISTANCE,
                                                          costMax: 1)
    
    private var rawPoints: [Int] = [Int]()
    
    weak var view: UIView?
    weak var delegate: AllegroGestureDelegate?

    // TODO we should probably make it explicit that this class will add gesture recognizers to the view
    init(view: UIView) {
        self.view = view
        setupTapGestures()
        setupSwipeGestures()
    }
    
    private func setupTapGestures() {
        let doubleDot = UITapGestureRecognizer(target: self, action: #selector(tapped))
        doubleDot.numberOfTapsRequired = 3
        let dot = UITapGestureRecognizer(target: self, action: #selector(tapped))
        dot.numberOfTapsRequired = 2
        let note = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        dot.require(toFail: doubleDot)
        note.require(toFail: dot)
        
        for gr in [doubleDot, dot, note] {
            view?.addGestureRecognizer(gr)
        }
    }
    
    private func setupSwipeGestures() {
        let map: [AllegroGesture:[Int]] = [
            .flat: [0,2],
            .sharp: [0,6],
            .natural: [0],
            .rest: [3],
            ]
        for (gesture, pattern) in map {
            let any = gesture as AnyObject
            let p = PathModel(directions: pattern, datas: any)
            swipeGestureRecognizer.addModel(p)
        }
    }
    
    func reset() {
        rawPoints = []
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first, let view = view {
            reset()
            let location = t.location(in: view)
            rawPoints.append(Int(location.x))
            rawPoints.append(Int(location.y))
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first, let view = view, rawPoints.count >= 2 {
            let location = t.location(in: view)
            let xNotTheSame = rawPoints[rawPoints.count-2] != Int(location.x)
            let yNotTheSame = rawPoints[rawPoints.count-1] != Int(location.y)
            if (xNotTheSame && yNotTheSame) {
                rawPoints.append(Int(location.x))
                rawPoints.append(Int(location.y))
            }
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var path = Path()
        path.addPointFromRaw(rawPoints)
        if let gesture = swipeGestureRecognizer.recognizePath(path),
            let type = gesture.datas as? AllegroGesture,
            rawPoints.count > 2 {
            let point = CGPoint(x: rawPoints[0], y: rawPoints[1])
            delegate?.actionGestureRecognized(gesture: type, at: point)
        }
        // TODO notify delegate
    }

    @objc private func tapped(sender: UITapGestureRecognizer) {
        guard let view = view else { return }
        let point = sender.location(in: view)
        switch sender.numberOfTapsRequired {
        case 1:
            delegate?.actionGestureRecognized(gesture: .note, at: point)
        case 2:
            delegate?.actionGestureRecognized(gesture: .dot, at: point)
        case 3:
            delegate?.actionGestureRecognized(gesture: .doubleDot, at: point)
        default: break
        }
    }
}
