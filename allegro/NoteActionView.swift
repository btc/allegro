//
//  AbstractNoteView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class NoteActionView: UIView {

    let note: NoteViewModel
    let geometry: NoteGeometry
    let store: PartStore

    // view's hit area is scaled by this factor
    let hitAreaScaleFactor: CGFloat = 1.5

    weak var delegate: NoteActionDelegate?

    fileprivate let swipe: NoteSwipeActionGestureRecognizer = {
        let gr = NoteSwipeActionGestureRecognizer()
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

    init(note: NoteViewModel, geometry: NoteGeometry, store: PartStore) {
        self.note = note
        self.geometry = geometry
        self.store = store
        super.init(frame: .zero)
        store.subscribe(self)
        clipsToBounds = false
        let actionRecognizers: [(Selector, UIGestureRecognizer)] = [
            (#selector(swiped), swipe),
            (#selector(tapped), dot),
            (#selector(tapped), doubleDot),
            ]
        for (sel, gr) in actionRecognizers {
            gr.addTarget(self, action: sel)
            addGestureRecognizer(gr)
            gr.delegate = self
        }
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
            case 2:
                delegate?.actionRecognized(gesture: .toggleDot, by: self)
            case 3:
                delegate?.actionRecognized(gesture: .toggleDoubleDot, by: self)
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

        let gestureIsOurSwipeRecognizer = gestureRecognizer == swipe
        let gestureIsOneOfOurTapRecognizers = gestureRecognizer == dot || gestureRecognizer == doubleDot
        let otherIsATapRecognizer = otherGestureRecognizer as? UITapGestureRecognizer != nil
        let thisIsTapAndOtherIsAlsoTapButNotOurTap = gestureIsOneOfOurTapRecognizers && otherIsATapRecognizer

        return gestureIsOurSwipeRecognizer || thisIsTapAndOtherIsAlsoTapButNotOurTap
    }
}

extension NoteActionView: PartStoreObserver {
    func partStoreChanged() {
        for r in [swipe, dot, doubleDot] {
            r.isEnabled = store.mode == .edit
        }
    }
}
