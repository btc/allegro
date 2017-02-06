//
//  MeasureActionGestureRecognizer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/23/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum MeasureAction: String {
    case flat
    case sharp
    case natural
    case rest
    case undot // tap
    case dot // TODO(btc): double tap?
    case doubleDot // TODO(btc): triple tap?
}

protocol MeasureActionDelegate: class {
    func actionRecognized(gesture: MeasureAction, at location: CGPoint)
}

class MeasureActionGestureRecognizer: UIGestureRecognizer {

    var delta: Double = 22
    var costMax = 1

    weak var actionDelegate: MeasureActionDelegate?

    private var tapGestureRecognizers = [UITapGestureRecognizer]()
    private let swipeGestureRecognizer: DBPathRecognizer?
    private var rawPoints = [Int]()

    // installs gesture recognizers on the view
    // this object does NOT hold a reference to the view
    // clienst must NOT call view.addGestureRecognizer(thisObject)
    init(view: UIView) {
        swipeGestureRecognizer = DBPathRecognizer(sliceCount: 8,
                                                  deltaMove: delta,
                                                  costMax: costMax)
        super.init(target: nil, action: nil)
        view.addGestureRecognizer(self)
        setupSwipeGestures()
        setupTapGestures(view)
    }

    private func setupTapGestures(_ view: UIView) {
        let note = UITapGestureRecognizer(target: self, action: #selector(tapped))

        for gr in [note] {
            view.addGestureRecognizer(gr)
        }
    }

    private func setupSwipeGestures() {
        let map: [MeasureAction : [Int]] = [
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
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        if let t = touches.first, let view = view {
            let location = t.location(in: view)
            rawPoints.append(Int(location.x))
            rawPoints.append(Int(location.y))
        }
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
        defer { reset() }

        var path = Path()
        path.addPointFromRaw(rawPoints)
        if let gesture = swipeGestureRecognizer?.recognizePath(path),
            let type = gesture.datas as? MeasureAction,
            rawPoints.count > 2 {
            let point = CGPoint(x: rawPoints[0], y: rawPoints[1])
            actionDelegate?.actionRecognized(gesture: type, at: point)
        }
    }

    @objc private func tapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let point = sender.location(in: view)
        switch sender.numberOfTapsRequired {
        case 1:
            actionDelegate?.actionRecognized(gesture: .undot, at: point)
        case 2:
            actionDelegate?.actionRecognized(gesture: .dot, at: point)
        case 3:
            actionDelegate?.actionRecognized(gesture: .doubleDot, at: point)
        default: break
        }
    }
}
