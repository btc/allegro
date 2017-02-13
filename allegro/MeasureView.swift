//
//  MeasureView.swift
//  allegro
//
//  Created by Qingping He on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import UIKit
import Rational

class MeasureView: UIView {

    var geometry: MeasureGeometry = .zero {
        didSet {
            frame.size = geometry.frameSize
        }
    }

    var store: PartStore? {
        willSet {
            store?.unsubscribe(self)
        }
        didSet {
            store?.subscribe(self)
        }
    }

    var index: Int?

    fileprivate let staffLineThickness: CGFloat = 2

    fileprivate let barThickness: CGFloat = 5

    fileprivate let barLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()

    fileprivate let editTapGR: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer()
        return gr
    }()

    fileprivate let editPanGR: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer()
        gr.minimumNumberOfTouches = 1
        gr.maximumNumberOfTouches = 1
        gr.cancelsTouchesInView = false // TODO: why?
        return gr
    }()

    fileprivate let eraseGR: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer()
        gr.minimumNumberOfTouches = 1
        gr.maximumNumberOfTouches = 1
        gr.cancelsTouchesInView = false
        return gr
    }()

    // screenEdgeGR exists to prevent the other recognizers from being triggered when user tries to open the side menu
    fileprivate let screenEdgeGR: UIScreenEdgePanGestureRecognizer = {
        let gr = UIScreenEdgePanGestureRecognizer()
        gr.edges = [.right]
        return gr
    }()

    fileprivate let touchGuide: UIView = {
        let v = MeasureTouchGuide()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(barLayer)

        // iOS expects draw(rect:) to completely fill
        // the view region with opaque content. This causes
        // the view background to be black unless we disable this.
        self.isOpaque = false
        backgroundColor = .white

        let actionRecognizers: [(Selector, UIGestureRecognizer)] = [
            (#selector(editTap), editTapGR),
            (#selector(editPan), editPanGR),
            (#selector(erase), eraseGR),
            ]
        for (sel, gr) in actionRecognizers {
            gr.addTarget(self, action: sel)
            addGestureRecognizer(gr)
            gr.require(toFail: screenEdgeGR) // so user can open side menu without accidentally erasing, etc.
            gr.delegate = self
        }
        addGestureRecognizer(screenEdgeGR)
    }

    deinit {
        store?.unsubscribe(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(_: rect)

        drawVerticalGridlines(rect: rect)
        drawStaffs(rect: rect)
        drawLedgerLineGuides(rect: rect)
    }

    private func drawStaffs(rect: CGRect) {
        let path = UIBezierPath()
        for (start, end) in geometry.staffLines {
            path.move(to: start)
            path.addLine(to: end)
        }
        path.lineWidth = staffLineThickness
        UIColor.black.setStroke()
        path.stroke()
    }

    private func drawLedgerLineGuides(rect: CGRect) {
        let path = UIBezierPath()
        for (start, end) in geometry.ledgerLineGuides {

            path.move(to: start)
            path.addLine(to: end)
        }

        path.lineCapStyle = .round
        let dashes: [CGFloat] = [1, 10]
        path.setLineDash(dashes, count: dashes.count, phase: 0)

        UIColor.lightGray.setStroke()
        path.stroke()
    }
    
    private func drawVerticalGridlines(rect: CGRect) {
        guard let store = store, let index = index else { return }
        
        let measure = store.measure(at: index)
        
        let lines = geometry.verticalGridlines(measure: measure,
                                               timeSignature: measure.timeSignature)
        
        let path = UIBezierPath()

        for (start, end) in lines {

            path.move(to: start)
            path.addLine(to: end)
        }
        path.lineCapStyle = .round
        let dashes: [CGFloat] = [1, 10]
        path.setLineDash(dashes, count: dashes.count, phase: 0)

        UIColor.lightGray.setStroke()
        path.stroke()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(touchGuide)

        guard let store = store, let index = index else { return }

        let measureVM = store.measure(at: index)
        let noteViewModels = measureVM.noteViewModels
        let g = geometry.noteGeometry
        let noteViews = noteViewModels.map { NoteView(note: $0, geometry: g) }
        noteViews.forEach() { $0.delegate = self }
        let notesToNoteView = noteViewModels.enumerated()
            .map{return ($1, noteViews[$0])}
            .reduce([Int: NoteView]()) {
                (dict: [Int:NoteView], kv: (NoteViewModel, NoteView)) -> [Int:NoteView]  in
                var out = dict
                out[ObjectIdentifier(kv.0).hashValue] = kv.1
                return out
            }

        // TODO(btc): size the notes based on noteHeight
        for v in noteViews {
            addSubview(v)
        }
        
        let ts = measureVM.timeSignature
        let spacing = geometry.generateSpacing(measure: measureVM, timeSig: ts)
        
        for noteView in noteViews {
            let slot = geometry.noteToSlot(position: noteView.note.position, timeSig: ts)
            // TODO(btc): render note in correct position in time, taking into consideration:
            // * note should be in the center of the spot available to it
            // * there should be a minimum spacing between notes
            let x = geometry.noteX(spacing: spacing, slot: slot)
            let y = geometry.noteY(pitch: noteView.note.pitch)
            
            noteView.shouldDrawFlag = true//false
            
            var noteGeometry = noteView.geometry
            
            // we still need to handle multiple notes in one column and lay them one after each other
            // but for now we just lay them overlapping
            let origin = CGPoint(x: x + spacing[slot] - noteGeometry.frame.size.width, y: y)
            noteGeometry.origin = origin
            noteView.frame = noteGeometry.frame

            if let a = getAccidentalLabel(noteView: noteView) {
                addSubview(a)
            }
        }
        
        let barPath = UIBezierPath()
        
        for beam in measureVM.beams {
            var barStart = CGPoint.zero
            var barEnd = CGPoint.zero
            
            for (i, noteViewModel) in beam.enumerated() {
                guard let noteView = notesToNoteView[ObjectIdentifier(noteViewModel).hashValue] else {
                    continue
                }
                noteView.shouldDrawFlag = false
                
                let flagStart = noteView.frame.origin + noteView.flagStart
                
                if (i == 0) {
                    barStart = flagStart
                }
                
                if (i == beam.count - 1) {
                    barEnd = flagStart.offset(dx: noteView.stemThickness, dy: 0)
                    
                    var next = barStart
                    barPath.move(to: next)
                    next = barEnd
                    barPath.addLine(to: next)
                    next = CGPoint(x: barEnd.x, y: barEnd.y + barThickness)
                    barPath.addLine(to: next)
                    next = CGPoint(x: barStart.x, y: barStart.y + barThickness)
                    barPath.addLine(to: next)
                    barPath.close()
                }
            }
        }
           
        barLayer.path = barPath.cgPath
        barLayer.fillColor = UIColor.black.cgColor

        // we compute paths at the end because beams can change stuff
        for noteView in noteViews {
            noteView.computePaths()
        }
    }
    


    func getAccidentalLabel(noteView: NoteView) -> UILabel? {
        guard noteView.note.displayAccidental else { return nil }
        let accidental = noteView.note.accidental
        let label = UILabel()
        label.frame = noteView.geometry.getAccidentalFrame(note: noteView.note)
        label.text = accidental.infos.0
        label.font = UIFont(name: "DejaVu Sans", size: 70)
        label.textAlignment = .right
        return label
    }

    func erase(sender: UIPanGestureRecognizer) {
        guard store?.mode == .erase else { return }
        
        let location = sender.location(in: self)

        if let nv = hitTest(location, with: nil) as? NoteView {
            guard let store = store, let index = index else { return }
            store.removeNote(fromMeasureIndex: index, at: nv.note.position)
        }
    }

    func editTap(sender: UIGestureRecognizer) {
        guard store?.mode == .edit else {
            Snackbar(message: "you're in erase mode", duration: .short).show()
            return
        }
        let location = sender.location(in: self)

        guard let store = store, let index = index else { return }
        let value = store.selectedNoteValue

        // determine pitch
        let pitchRelativeToCenterLine = geometry.pointToPitch(location)

        // determine position
        let measure = store.measure(at: index)
        let position = geometry.pointToPositionInTime(x: location.x,
                                                      timeSignature: measure.timeSignature)

        // instantiate note
        let (letter, octave) = NoteViewModel.pitchToLetterAndOffset(pitch: pitchRelativeToCenterLine)
        let note = Note(value: value, letter: letter, octave: octave)

        // attempt to insert
        let succeeded = store.insert(note: note, intoMeasureIndex: index, at: position)

        if !succeeded {
            Snackbar(message: "no space for note", duration: .short).show()
        }
    }

    func editPan(sender: UIPanGestureRecognizer) {
        guard store?.mode == .edit else { return }

        guard let store = store, let index = index else { return }
        let ts = store.measure(at: index).timeSignature

        if sender.state == .ended {
            let end = sender.location(in: self)
            let start = end - sender.translation(in: self)
            if geometry.touchRemainedInPosition(start: start,
                                                end: end,
                                                timeSignature: ts) {
                editTap(sender: sender)
            }
        } else if sender.state == .changed {
            let rect = geometry.touchGuideRect(location: sender.location(in: self),
                                               timeSignature: ts)
            touchGuide.frame = rect
        }

        touchGuide.isHidden = sender.state != .changed
    }
}

extension MeasureView: PartStoreObserver {
    func partStoreChanged() {
        guard let store = store else { return }

        eraseGR.isEnabled = store.mode == .erase
        editPanGR.isEnabled = store.mode == .edit

        if geometry.state.visibleSize != .zero {
            let state = MeasureGeometry.State(visibleSize: geometry.state.visibleSize,
                                              selectedNoteDuration: store.selectedNoteValue.nominalDuration)
            geometry = MeasureGeometry(state: state)
        }
        setNeedsDisplay() // TODO(btc): perf: only re-draw when changing note selection
        setNeedsLayout()
    }
}

extension MeasureView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case eraseGR: return store?.mode == .erase
        case editPanGR: return store?.mode == .edit
        default: return true
        }
    }
}

extension MeasureView: NoteActionDelegate {
    func actionRecognized(gesture: NoteAction, by view: UIView) {

        guard let store = store, let index = index, let pos = (view as? NoteActionView)?.note.position else { return }

        guard store.mode == .edit else {
            if store.mode == .erase && gesture == .undot { // i.e. the user tapped on note
                store.removeNote(fromMeasureIndex: index, at: pos)
            }
            return
        }

        switch gesture {

        case .undot, .dot, .doubleDot:
            let dot: Note.Dot = gesture == .undot ? .none : gesture == .dot ? .single : .double
            if !store.dotNote(inMeasure: index, at: pos, dot: dot) {
                let action = gesture.description
                Snackbar(message: "not enough space to \(action) note", duration: .short).show()
            }

        case .sharp, .natural, .flat:
            let acc: Note.Accidental = gesture == .sharp ? .sharp : gesture == .flat ? .flat : .natural
            if !store.setAccidental(acc, inMeasure: index, at: pos) {
                Snackbar(message: "failed to \(gesture) the note", duration: .short).show()
            }

        case .rest:
            if !store.changeNoteToRest(inMeasure: index, at: pos) {
                Snackbar(message: "failed to convert note to rest", duration: .short).show()
            }
        }
    }
}

extension Note.Accidental {
    // We draw the accidentals relate the the head of the note.
    // The offset specifies a small delta since we need the flat
    // to be slightly higher than the other accidentals to align with
    // the measure line
    var infos: (String, CGPoint) {
        switch self {
        case .natural: return ("♮", CGPoint(x: -20, y: 0))
        case .sharp: return ("♯", CGPoint(x: -20, y: 0))
        case .flat: return ("♭", CGPoint(x: -20, y: -12))
        default: return ("", .zero)
        }
    }
}
