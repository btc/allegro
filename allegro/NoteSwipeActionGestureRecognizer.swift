//
//  MeasureActionGestureRecognizer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/23/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum NoteSwipeAction: String {
    case flat
    case sharp
    case natural
    case rest
}

protocol NoteSwipeActionDelegate: class {
    func actionRecognized(gesture: NoteSwipeAction, at location: CGPoint)
}

class NoteSwipeActionGestureRecognizer: UIGestureRecognizer {

    var action: NoteSwipeAction?

    // TODO: allow tweaks
    let delta: Double = 22
    let costMax = 1

    weak var actionDelegate: NoteSwipeActionDelegate?

    private let swipeGestureRecognizer: DBPathRecognizer?
    private var rawPoints = [Int]()

    // installs gesture recognizers on the view
    // this object does NOT hold a reference to the view
    // clienst must NOT call view.addGestureRecognizer(thisObject)

    override init(target: Any?, action: Selector?) {
        swipeGestureRecognizer = DBPathRecognizer(sliceCount: 8,
                                                  deltaMove: delta,
                                                  costMax: costMax)
        super.init(target: target, action: action)
        setupSwipeGestures()
    }

    private func setupSwipeGestures() {
        let map: [NoteSwipeAction : [Int]] = [
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

    override func reset() {
        super.reset()
        rawPoints = []
        state = .possible
        action = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        guard let t = touches.first, let view = view else {
            state = .failed
            return
        }
        let location = t.location(in: view)
        rawPoints.append(Int(location.x))
        rawPoints.append(Int(location.y))
        state = .began
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        var path = Path()
        path.addPointFromRaw(rawPoints)

        guard let gesture = swipeGestureRecognizer?.recognizePath(path),
            let type = gesture.datas as? NoteSwipeAction,
            rawPoints.count > 2 else {
                state = .failed
                return
        }

        let point = CGPoint(x: rawPoints[0], y: rawPoints[1])
        actionDelegate?.actionRecognized(gesture: type, at: point)
        action = type
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }
}
