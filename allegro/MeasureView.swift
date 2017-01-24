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

    fileprivate static func staffHeight(visibleHeight: CGFloat) -> CGFloat {
        return (visibleHeight - 2 * DEFAULT_MARGIN_PTS) / CGFloat(staffCount + 1)
    }

    static func totalHeight(visibleHeight: CGFloat) -> CGFloat {
        // - 1 because we're counting the spaces between ledger lines
        // 2 * Margin because we leave a little space above the top and bottom ledger lines
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        return staffHeight(visibleHeight: visibleHeight) * numSpacesBetweenAllLines + 2 * DEFAULT_MARGIN_PTS
    }

    var store: PartStore?

    var index: Int?

    var staffLineThickness: CGFloat = 0

    var sizeOfParentsVisibleArea: CGSize? {
        didSet {
            guard let sizeOfParentsVisibleArea = sizeOfParentsVisibleArea else { return }
            frame.size = CGSize(width: sizeOfParentsVisibleArea.width,
                                height: MeasureView.totalHeight(visibleHeight: sizeOfParentsVisibleArea.height))
        }
    }

    fileprivate var staffHeight: CGFloat {
        return MeasureView.staffHeight(visibleHeight: visibleHeight)
    }

    // there are two 'heights' that we care about: _visible_ height and _total_ height. Visible height is what is
    // visible in edit mode. Total height is what is visible in view mode.
    fileprivate var visibleHeight: CGFloat {
        return sizeOfParentsVisibleArea?.height ?? 0
    }

    fileprivate var staffDrawStart: CGFloat {
        return DEFAULT_MARGIN_PTS + CGFloat(MeasureView.numLedgerLinesAbove) * staffHeight
    }

    fileprivate static let staffCount = 5
    fileprivate static let numLedgerLinesAbove = 4
    fileprivate static let numLedgerLinesBelow = 4

    fileprivate let noteWidth = CGFloat(100)
    fileprivate var noteHeight: CGFloat { return staffHeight }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // iOS expects draw(rect:) to completely fill
        // the view region with opaque content. This causes
        // the view background to be black unless we disable this.
        self.isOpaque = false
        backgroundColor = .white

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(_: rect)

        for i in 0..<MeasureView.staffCount {
            let path = UIBezierPath(rect: CGRect(
                x: 0,
                y: staffDrawStart + CGFloat(i) * staffHeight - staffLineThickness / 2,
                width: rect.width,
                height: staffLineThickness
                )
            )

            UIColor.black.setFill()
            path.fill()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { $0.removeFromSuperview() }

        guard let store = store, let index = index else { return }

        let notes = store.getNotes(measureIndex: index)
        let noteViewModels = notes.map { NoteViewModel(note: $0.note) }
        let noteViews = noteViewModels.map { NoteView(note: $0) }

        // TODO(btc): size the notes based on noteHeight
        for v in noteViews {
            addSubview(v)
        }

        for (i, noteView) in noteViews.enumerated() {
            let position = noteView.note.pitch

            // TODO(btc): render note in correct position in time, taking into consideration:
            // * note should be in the center of the spot available to it
            // * there should be a minimum spacing between notes

            let x = notes[i].pos.cgFloat * bounds.width
            let y = staffDrawStart + staffHeight * 2 - staffHeight / 2 * CGFloat(position) - noteHeight / 2
            
            let end = position > 0 ? y + noteHeight + 100 : y - 100
            
            noteView.noteFrame = CGRect(x: x, y: y, width: noteWidth, height: noteHeight)
            noteView.stemEndY = CGFloat(end)
        }
    }

    @objc private func tapped(sender: UITapGestureRecognizer) {
        let p = sender.location(in: self)
        guard let store = store, let index = index else { return }
        let duration = store.selectedNoteDuration

        // determine pitch
        let pitchRelativeToCenterLine = pointToPitch(p)

        // determine position
        let measure = store.measure(at: index)
        guard let rational = pointToPositionInTime(p, timeSignature: measure.timeSignature, noteDuration: duration) else {
            Log.error?.message("failed to convert user's touch into a position in time")
            return
        }

        // instantiate note
        let (letter, octave) = NoteViewModel.pitchToLetterAndOffset(pitch: pitchRelativeToCenterLine)
        let note = Note(duration: duration, letter: letter, octave: octave)

        // attempt to insert
        let succeeded = store.insert(note: note, intoMeasureIndex: index, at: rational)

        if !succeeded {
            // TODO(btc): display helpful feedback to the user
        }

        setNeedsLayout()

        Log.info?.value(succeeded)
    }

    private func pointToPitch(_ point: CGPoint) -> Int {
        let numSpacesBetweenAllLines: CGFloat = CGFloat(MeasureView.staffCount + MeasureView.numLedgerLinesAbove + MeasureView.numLedgerLinesBelow - 1)
        let lengthOfSemitoneInPoints = staffHeight / 2
        return Int(round(-(point.y - DEFAULT_MARGIN_PTS) / lengthOfSemitoneInPoints + numSpacesBetweenAllLines))
    }

    private func pointToPositionInTime(_ point: CGPoint, timeSignature: Rational, noteDuration: Note.Duration) -> Rational? {
        let numPositionsInTime = timeSignature.numerator // TODO(btc): take into consideration the selected note's duration
        let ratioOfScreenWidth = point.x / bounds.width
        let positionInTime = Int(floor(ratioOfScreenWidth * CGFloat(numPositionsInTime)))
        return Rational(positionInTime, numPositionsInTime)
    }
}
