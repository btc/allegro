//
//  MeasureActionGestureRecognizer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/23/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class NoteSwipeActionGestureRecognizer: UIGestureRecognizer {

    var action: NoteAction?

    private var start: CGPoint?

    override func reset() {
        super.reset()
        state = .possible
        action = nil
        start = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {

        guard let t = touches.first, let view = view else {
            state = .failed
            return
        }
        start = t.location(in: view)
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {

        guard let start = start, let t = touches.first, let view = view else {
            state = .failed
            return
        }
        let end = t.location(in: view)

        if start.distance(to: end) < 15 {
            state = .failed
            return
        }

        switch start.angle(to: end) {
        case -15 ... 15:
            action = .natural
        case 15 ... 90:
            action = .flat
        case 90 ... 180:
            action = .rest
        case -90 ... -15:
            action = .sharp
        default:
            state = .failed
            return
        }

        state = .recognized
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
