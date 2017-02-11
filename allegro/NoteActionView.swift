//
//  AbstractNoteView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class NoteActionView: UIView {

    var note: NoteViewModel
    var geometry: NoteGeometry

    // view's hit area is scaled by this factor
    let hitAreaScaleFactor: CGFloat = 1.5

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

    init(note: NoteViewModel, geometry: NoteGeometry) {
        self.note = note
        self.geometry = geometry
        super.init(frame: .zero)
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
            delegate?.actionRecognized(gesture: action, by: self)
        }
    }

    func tapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            switch sender.numberOfTapsRequired {
            case 1:
                delegate?.actionRecognized(gesture: .undot, by: self)
            case 2:
                delegate?.actionRecognized(gesture: .dot, by: self)
            case 3:
                delegate?.actionRecognized(gesture: .doubleDot, by: self)
            default: break
            }
        }
        Log.warning?.value(sender.numberOfTapsRequired)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if let pointOf1stTouch = event?.allTouches?.first?.location(in: self) {
            return super.hitTest(pointOf1stTouch, with: event)
        }
        if isHidden || !isUserInteractionEnabled || self.alpha < 0.01 { return nil }

        let widthToAdd = hitAreaScaleFactor * bounds.width - bounds.width
        let heightToAdd = hitAreaScaleFactor * bounds.height - bounds.height
        let largerBounds = bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        return largerBounds.contains(point) ? self : nil
    }
}

extension NoteActionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == swipe
    }
}
