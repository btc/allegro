//
//  AbstractNoteView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class NoteActionView: UIView {

    weak var delegate: NoteActionDelegate?

    fileprivate let swipe: NoteSwipeActionGestureRecognizer = {
        let gr = NoteSwipeActionGestureRecognizer()
        return gr
    }()

    fileprivate let undot: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer()
        gr.numberOfTouchesRequired = 1
        gr.numberOfTapsRequired = 1
        return gr
    }()

    fileprivate let dot: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer()
        gr.numberOfTouchesRequired = 1
        gr.numberOfTapsRequired = 2
        return gr
    }()

    fileprivate let doubleDot: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer()
        gr.numberOfTouchesRequired = 1
        gr.numberOfTapsRequired = 3
        return gr
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        let actionRecognizers: [(Selector, UIGestureRecognizer)] = [
            (#selector(swiped), swipe),
            (#selector(tapped), undot),
            (#selector(tapped), dot),
            (#selector(tapped), doubleDot),
            ]
        for (sel, gr) in actionRecognizers {
            gr.addTarget(self, action: sel)
            addGestureRecognizer(gr)
            gr.delegate = self
        }
        undot.require(toFail: dot)
        dot.require(toFail: doubleDot)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    func swiped(sender: NoteSwipeActionGestureRecognizer) {
        if let action = sender.action {
            delegate?.actionRecognized(gesture: action, at: frame.origin)
        }
    }

    func tapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            switch sender.numberOfTapsRequired {
            case 1:
                delegate?.actionRecognized(gesture: .undot, at: frame.origin)
            case 2:
                delegate?.actionRecognized(gesture: .dot, at: frame.origin)
            case 3:
                delegate?.actionRecognized(gesture: .doubleDot, at: frame.origin)
            default: break
            }
        }
        Log.warning?.value(sender.numberOfTapsRequired)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if let pointOf1stTouch = event?.allTouches?.first?.location(in: self) {
            return super.hitTest(pointOf1stTouch, with: event)
        }
        return super.hitTest(point, with: event)
    }
}

extension NoteActionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == swipe
    }
}
