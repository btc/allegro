//
//  AllegroGestureRecognizer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

enum ActionGesture: String {
    case note // tap
    case flat
    case sharp
    case natural
    case rest
    case dot // TODO(btc): double tap?
    case doubleDot // TODO(btc): triple tap?
    case chord // TODO(btc): should we include this at all?
}

protocol ActionGestureDelegate: class {
    func actionGestureRecognized(gesture: ActionGesture, at location: CGPoint)
}

// TODO(btc): Note that one obvious improvement is to subclass UIGestureRecognizer. That makes it so that clients don't
// have to delegate their touches(Began|Moved|Ended) methods to this class. Instead, with the subclass, the UIKit framework
// will be responsible for calling our methods and managing our state. However, this alternative limits us when it comes
// time to report which action was recognized. The addTarget method on the subclass doesn't allow us to communicate which
// action was recognized (as our ActionGestureDelegate protocol does). For this reason, I'm not convinced it's worth the
// rewrite at this time. However, if this class introduces problems, let this note be a guide towards an alternative design
// with slightly different constraints and benefits.
class ActionGestureRecognizer {

    var delta: Double = 22
    var costMax = 1

    private let swipeGestureRecognizer: DBPathRecognizer?
    private var rawPoints: [Int] = [Int]()

    weak var view: UIView?
    weak var delegate: ActionGestureDelegate?

    // TODO we should probably make it explicit that this class will add gesture recognizers to the view.
    init(view: UIView) {
        self.view = view
        swipeGestureRecognizer = DBPathRecognizer(sliceCount: 8,
                         deltaMove: delta,
                         costMax: costMax)
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
        let map: [ActionGesture : [Int]] = [
            .flat: [0,2],
            .sharp: [0,6],
            .natural: [0],
            .rest: [3],
            ]
        for (gesture, pattern) in map {
            let any = gesture as AnyObject
            let p = PathModel(directions: pattern, datas: any)
            swipeGestureRecognizer?.addModel(p)
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
            let xIsDifferent = rawPoints[rawPoints.count-2] != Int(location.x)
            let yIsDifferent = rawPoints[rawPoints.count-1] != Int(location.y)
            if (xIsDifferent || yIsDifferent) {
                rawPoints.append(Int(location.x))
                rawPoints.append(Int(location.y))
            }
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var path = Path()
        path.addPointFromRaw(rawPoints)
        if let gesture = swipeGestureRecognizer?.recognizePath(path),
            let type = gesture.datas as? ActionGesture,
            rawPoints.count > 2 {
            let point = CGPoint(x: rawPoints[0], y: rawPoints[1])
            delegate?.actionGestureRecognized(gesture: type, at: point)
        }
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
