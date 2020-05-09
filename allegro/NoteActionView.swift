//
//  AbstractNoteView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class NoteActionView: UIView {

    var note: NoteViewModel {
        willSet {
            dotView?.removeFromSuperview()
        }
        didSet {
            dotView = createDotView()
            if let d = dotView {
                addSubview(d)
            }
        }
    }
    
    let geometry: NoteGeometry
    let store: PartStore
    
    var dotView: UIView?

    var isSelected: Bool = false {
        didSet {
            color = isSelected ? .allegroBlue : .black
            setNeedsDisplay()

            updateRecognizers()
        }
    }
    var color: UIColor = .black

    // view's hit area is scaled by this factor
    let hitAreaScaleFactor: CGFloat = 1.5

    weak var delegate: NoteActionDelegate?

    fileprivate let swipe: NoteSwipeActionGestureRecognizer = {
        let gr = NoteSwipeActionGestureRecognizer()
        return gr
    }()

    fileprivate let move: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer()
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

    fileprivate let select: UILongPressGestureRecognizer = {
        let gr = UILongPressGestureRecognizer()
        gr.minimumPressDuration = 0.2
        return gr
    }()
    
    func createDotView() -> UIView? {
        guard note.note.dot != .none else { return nil }
        
        let view = UIView()
        let dframe = geometry.getDotBoundingBox(note: note)
        view.frame = dframe
        let dotLayer = CAShapeLayer()
        let dotSize = CGSize(width: 2 * geometry.dotRadius, height: 2 * geometry.dotRadius)
        let dotPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: dotSize))
        
        if note.note.dot == .double {
            let secondDotOrigin = CGPoint.zero.offset(dx: dframe.size.width - dotSize.width, dy: 0)
            dotPath.append(UIBezierPath(ovalIn: CGRect(origin: secondDotOrigin, size:dotSize)))
        }
        
        dotLayer.path = dotPath.cgPath
        dotLayer.fillColor = UIColor.black.cgColor
        view.layer.addSublayer(dotLayer)
        return view
    }

    init(note: NoteViewModel, geometry: NoteGeometry, store: PartStore) {
        self.note = note
        self.geometry = geometry
        self.store = store
        super.init(frame: .zero)
        
        store.subscribe(self)
        clipsToBounds = false
        let actionRecognizers: [(Selector, UIGestureRecognizer)] = [
            (#selector(moved), move),
            (#selector(swiped), swipe),
            (#selector(tapped), dot),
            (#selector(tapped), doubleDot),
            (#selector(selected), select),
            ]
        for (sel, gr) in actionRecognizers {
            gr.addTarget(self, action: sel)
            addGestureRecognizer(gr)
            gr.delegate = self
        }
        dot.require(toFail: doubleDot)

        for gr: UIGestureRecognizer in [dot, doubleDot, swipe] {
            gr.require(toFail: select)
        }
        
        // call didSet
        defer {
            self.note = note
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    @objc func moved(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        if let v = sender.view, sender.state != .ended {
            let newX = v.center.x + translation.x
            let newY = v.center.y + translation.y
            v.center = CGPoint(x: newX, y: newY)
            sender.setTranslation(.zero, in: self)
        }

        if sender.state == .ended {
            delegate?.actionRecognized(gesture: .move, by: self)
        }
    }

    @objc func selected(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.actionRecognized(gesture: .select, by: self)
        }
        if sender.state == .changed {
            center = sender.location(in: superview)
        }
        if sender.state == .ended {
            delegate?.actionRecognized(gesture: .move, by: self)
        }
    }

    @objc func swiped(sender: NoteSwipeActionGestureRecognizer) {
        if let action = sender.action {
            delegate?.actionRecognized(gesture: action, by: self)
        }
    }

    @objc func tapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            switch sender.numberOfTapsRequired {
            case 2:
                delegate?.actionRecognized(gesture: .toggleDot, by: self)
            case 3:
                delegate?.actionRecognized(gesture: .toggleDoubleDot, by: self)
            default: break
            }
        }
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

    func updateRecognizers() {
        [swipe, dot, doubleDot].forEach { $0.isEnabled = !isSelected && store.mode == .edit }
        move.isEnabled = isSelected && store.mode == .edit
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
        updateRecognizers()
    }
}
