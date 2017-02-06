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

    fileprivate let recognizers: [(Selector, UIGestureRecognizer)]

    override init(frame: CGRect) {
        recognizers = [
            (#selector(editTap), editTapGR),
            (#selector(editPan), editPanGR),
            (#selector(erase), eraseGR),
        ]

        super.init(frame: frame)
        
        self.layer.addSublayer(barLayer)
        // iOS expects draw(rect:) to completely fill
        // the view region with opaque content. This causes
        // the view background to be black unless we disable this.
        self.isOpaque = false
        backgroundColor = .white

        for (sel, gr) in recognizers {
            gr.addTarget(self, action: sel)
            addGestureRecognizer(gr)
            gr.delegate = self
        }
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

        let lines = geometry.verticalGridlines(timeSignature: measure.timeSignature,
                                               selectedNoteDuration: store.selectedNoteValue.nominalDuration)
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

        guard let store = store, let index = index else { return }

        let measureVM = store.measure(at: index)
        let noteViewModels = measureVM.noteViewModels
        let g = geometry.noteGeometry
        let noteViews = noteViewModels.map { NoteView(note: $0, geometry: g) }

        // TODO(btc): size the notes based on noteHeight
        for v in noteViews {
            addSubview(v)
        }
        
        let barPath = UIBezierPath()
        var barStart = CGPoint.zero
        var barEnd = CGPoint.zero

        // we're barring all the notes for now
        for (i, noteView) in noteViews.enumerated() {
            // TODO(btc): render note in correct position in time, taking into consideration:
            // * note should be in the center of the spot available to it
            // * there should be a minimum spacing between notes
            let x = geometry.noteX(position: noteView.note.position,
                                   timeSignature: measureVM.timeSignature)
            let y = geometry.noteY(pitch: noteView.note.pitch)

            noteView.noteOrigin = CGPoint(x: x, y: y)
            noteView.stemEndY = geometry.noteStemEnd(pitch: noteView.note.pitch, originY: y)
            noteView.shouldDrawFlag = false
            
            let noteViewOrigin = noteView.frame.origin
            
            if (i == 0) {
                barStart = CGPoint(
                    x: noteViewOrigin.x + noteView.flagStart.x,
                    y: noteViewOrigin.y + noteView.flagStart.y
                )
            }
            
            if (i == noteViews.count - 1) {
                barEnd = CGPoint(
                    x: noteViewOrigin.x + noteView.flagStart.x + noteView.stemThickness,
                    y: noteViewOrigin.y + noteView.flagStart.y
                )
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

            if let a = getAccidentalLabel(noteView: noteView) {
                addSubview(a)
            }
        }
        
        barLayer.path = barPath.cgPath
        barLayer.fillColor = UIColor.black.cgColor
    }

    func getAccidentalLabel(noteView: NoteView) -> UILabel? {
        guard noteView.note.displayAccidental else { return nil }
        let accidental = noteView.note.accidental

        let center = CGPoint(x: noteView.noteFrame.origin.x,
                             y: noteView.noteFrame.origin.y + noteView.noteFrame.size.height / 2)

        let info = accidental.infos

        let offset = info.1

        let size = CGSize(width: 50, height: 60)
        let origin = CGPoint(x: center.x - size.width / 2 + offset.x,
                             y: center.y - size.height / 2 + offset.y)

        let label = UILabel()
        label.frame = CGRect(origin: origin, size: size)
        label.text = info.0
        label.font = UIFont(name: "DejaVu Sans", size: 70)
        label.textAlignment = .right
        return label
    }

   func erase(sender: UIPanGestureRecognizer) {
        guard store?.mode == .erase else { return }

        let location = sender.location(in: self)

        // TODO(btc): if we wind up with lots of subviews, as an optimization, hold explicit references to the note views.

        for v in subviews {
            guard let nv = v as? NoteView else { continue }

            let locationInSubview = nv.convert(location, from: self)
            if nv.point(inside: locationInSubview, with: nil) {
                guard let store = store, let index = index else { return }

                store.removeNote(fromMeasureIndex: index, at: nv.note.position)
            }
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
                                                      timeSignature: measure.timeSignature,
                                                      noteDuration: value.nominalDuration)

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
        if sender.state == .ended {
            editTap(sender: sender)
        }
    }
}

extension MeasureView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let otherIsOneOfOurs = recognizers.contains() { $0.1 == otherGestureRecognizer }
        return !otherIsOneOfOurs // makes sure our gestures take lower priority
    }
}

extension MeasureView: PartStoreObserver {
    func partStoreChanged() {
        guard let store = store else { return }

        eraseGR.isEnabled = store.mode == .erase
        editPanGR.isEnabled = store.mode == .edit

        let state = MeasureGeometry.State(visibleSize: geometry.state.visibleSize,
                                          selectedNoteDuration: store.selectedNoteValue.nominalDuration)
        geometry = MeasureGeometry(state: state)
        setNeedsDisplay() // TODO(btc): perf: only re-draw when changing note selection
        setNeedsLayout()
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
