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
            if let store = store {
                store.unsubscribe(self)
            }
        }
        didSet {
            if let store = store {
                store.subscribe(self)
            }
        }
    }

    var index: Int?

    fileprivate let barThickness = CGFloat(5)
    fileprivate let barLayer: CAShapeLayer
    
    // We draw the accidentals relate the the head of the note.
    // The offset specifies a small delta since we need the flat
    // to be slightly higher than the other accidentals to align with
    // the measure line
    fileprivate let accidentalInfos = [
        Note.Accidental.natural: ("♮", CGPoint(x: -20, y: 0)),
        Note.Accidental.sharp: ("♯", CGPoint(x: -20, y: 0)),
        Note.Accidental.flat: ("♭", CGPoint(x: -20, y: -12)),
        ]

    fileprivate let eraseGR: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer()
        gr.minimumNumberOfTouches = 1
        gr.maximumNumberOfTouches = 1
        gr.cancelsTouchesInView = false
        return gr
    }()

    override init(frame: CGRect) {
        barLayer = CAShapeLayer()
        super.init(frame: frame)
        
        self.layer.addSublayer(barLayer)
        // iOS expects draw(rect:) to completely fill
        // the view region with opaque content. This causes
        // the view background to be black unless we disable this.
        self.isOpaque = false
        backgroundColor = .white

        let mvaGR = MeasureActionGestureRecognizer(view: self)
        mvaGR.actionDelegate = self

        eraseGR.addTarget(self, action: #selector(erase))
        addGestureRecognizer(eraseGR)
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
    
    func getAccidentalLabel(noteView: NoteView) -> UILabel? {
        guard noteView.note.displayAccidental else { return nil }
        let accidental = noteView.note.accidental
        
        let center = CGPoint(
            x: noteView.noteFrame.origin.x,
            y: noteView.noteFrame.origin.y + noteView.noteFrame.size.height / 2)
        guard let info = accidentalInfos[accidental] else {
            return UILabel()
        }
        
        let offset = info.1
        
        let size = CGSize(width: 50, height: 60)
        let origin = CGPoint(
            x: center.x - size.width / 2 + offset.x,
            y: center.y - size.height / 2 + offset.y)
        
        let label = UILabel()
        label.frame = CGRect(origin: origin, size: size)
        label.text = info.0
        label.font = UIFont(name: "DejaVu Sans", size: 70)
        label.textAlignment = .right
        return label
    }

    private func drawStaffs(rect: CGRect) {
        for i in 0..<geometry.staffCount {
            // TODO(btc): replace rect with bezierPath.move, start, end, etc.
            let r = CGRect(x: 0,
                           y: geometry.staffDrawStart + CGFloat(i) * geometry.staffHeight - geometry.staffLineThickness / 2,
                           width: rect.width,
                           height: geometry.staffLineThickness)
            let path = UIBezierPath(rect: r)

            UIColor.black.setFill()
            path.fill()
        }
    }

    private func drawLedgerLineGuides(rect: CGRect) {

        let drawLine = { (y: CGFloat) -> Void in
            let path = UIBezierPath()

            let start = CGPoint(x: 0, y: y)
            let end = CGPoint(x: rect.width, y: y)

            path.move(to: start)
            path.addLine(to: end)

            path.lineCapStyle = .round
            let dashes: [CGFloat] = [1, 10]
            path.setLineDash(dashes, count: dashes.count, phase: 0)

            UIColor.lightGray.setStroke()
            path.stroke()
        }

        for i in stride(from: 0, to: geometry.numLedgerLinesAbove, by: 1) {
            let y = DEFAULT_MARGIN_PTS + geometry.staffHeight * CGFloat(i)
            drawLine(y)

        }

        for i in stride(from: 0, to: geometry.numLedgerLinesBelow, by: 1) {
            let m = DEFAULT_MARGIN_PTS
            let numLinesAbovePlusNumStaffs = CGFloat(geometry.numLedgerLinesAbove + geometry.staffCount)
            let staffHeight = geometry.staffHeight
            let y = m + numLinesAbovePlusNumStaffs * staffHeight + staffHeight * CGFloat(i)
            drawLine(y)
        }
    }

    private func drawVerticalGridlines(rect: CGRect) {
        guard let store = store, let index = index else { return }

        let measure = store.measure(at: index)
        
        guard store.selectedNoteValue.nominalDuration >= Note.Value.eighth.nominalDuration else { return }

        let numGridSlots = measure.timeSignature / store.selectedNoteValue.nominalDuration
        let numGridlines: Int = numGridSlots.intApprox - 1 // fence post
        let gridlineOffset = rect.width / numGridSlots.cgFloat

        for i in stride(from: 0, to: numGridlines, by: 1) {

            let path = UIBezierPath()

            let x = gridlineOffset * CGFloat(i + 1)
            let start = CGPoint(x: x, y: 0)
            let end = CGPoint(x: x, y: rect.height)
            path.move(to: start)
            path.addLine(to: end)

            path.lineCapStyle = .round
            let dashes: [CGFloat] = [1, 10]
            path.setLineDash(dashes, count: dashes.count, phase: 0)

            UIColor.lightGray.setStroke()
            path.stroke()
        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        subviews.forEach { $0.removeFromSuperview() }

        guard let store = store, let index = index else { return }

        let measureVM = store.measure(at: index)
        let noteViewModels = measureVM.noteViewModels
        let noteViews = noteViewModels.map { NoteView(note: $0) }

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

            // TODO(btc): perhaps just set noteView.geometry = geometry
            // and let everything else be a computed property
            noteView.staffHeight = geometry.staffHeight
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

    @objc private func erase(sender: UIPanGestureRecognizer) {
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
}

extension MeasureView: MeasureActionDelegate {

    func actionRecognized(gesture: MeasureAction, at location: CGPoint) {
        guard store?.mode == .edit else {
            Snackbar(message: "you're in erase mode", duration: .short).show()
            return
        }
        Log.info?.value(gesture.rawValue)

        guard let store = store, let index = index else { return }
        let value = store.selectedNoteValue

        // determine pitch
        let pitchRelativeToCenterLine = geometry.pointToPitch(location)

        // determine position
        let measure = store.measure(at: index)
        guard let rational = geometry.pointToPositionInTime(x: location.x,
                                                            timeSignature: measure.timeSignature,
                                                            noteDuration: value.nominalDuration) else {
            Log.error?.message("failed to convert user's touch into a position in time")
            return
        }

        // instantiate note
        let (letter, octave) = NoteViewModel.pitchToLetterAndOffset(pitch: pitchRelativeToCenterLine)
        let note = Note(value: value, letter: letter, octave: octave)

        // configure note
        switch gesture {
        case .dot: break // TODO(btc)
        case .doubleDot: break // TODO(btc)
        case .flat:
            note.accidental = .flat
        case .natural:
            note.accidental = .natural
        case .note: break // TODO(btc): remove dots
            // TODO(btc): note.rest = false ?
        case .rest:
            note.rest = true
        case .sharp:
            note.accidental = .sharp
        // TODO(btc): doubleSharp
        // TODO(btc): doubleFlat
        }

        // attempt to insert
        let succeeded = store.insert(note: note, intoMeasureIndex: index, at: rational)

        if succeeded {
            Log.info?.message("add note to measure: success!")
        } else {
            Log.info?.message("add note to measure: failure!")
            Snackbar(message: "No space for note", duration: .short).show()
        }
    }

}

extension MeasureView: PartStoreObserver {
    func partStoreChanged() {
        eraseGR.isEnabled = store?.mode == .erase
        setNeedsDisplay()
        setNeedsLayout()
    }
}
