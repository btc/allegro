//
//  MeasureGeometry.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational
import UIKit

// We are surrounded by space.
// And that space contains lots of things. 
// And these things have shapes.
// In MeasureGeometry, we are concerned with the nature of these things.

struct MeasureGeometry {

    typealias Line = (start: CGPoint, end: CGPoint)

    struct State {

        let visibleSize: CGSize
        let selectedNoteDuration: Rational

        init(visibleSize: CGSize, selectedNoteDuration: Rational) {
            self.visibleSize = visibleSize
            self.selectedNoteDuration = selectedNoteDuration
        }
    }

    static let zero = MeasureGeometry(state: State(visibleSize: .zero, selectedNoteDuration: 1))

    let state: State

    let staffCount = 5
    let numLedgerLinesAbove = 4
    let numLedgerLinesBelow = 4

    var minNoteWidth: CGFloat {
        return 1.5 * staffHeight
    }

    var staffDrawStart: CGFloat {
        return DEFAULT_MARGIN_PTS + CGFloat(numLedgerLinesAbove) * staffHeight
    }

    var staffHeight: CGFloat {
        return (state.visibleSize.height - 2 * DEFAULT_MARGIN_PTS) / CGFloat(staffCount + 1)
    }

    var heightOfSemitone: CGFloat {
        return staffHeight / 2
    }

    // it's a lot easier to compute width than height, so they are provided independently to allow clients to minimize
    // arithmetic operations

    var totalWidth: CGFloat {
        let minNoteWidth = Rational(Int(self.minNoteWidth))
        let numNotesPerMeasure = 1 / state.selectedNoteDuration
        let visibleWidth = state.visibleSize.width
        let reservedWidth = (minNoteWidth * numNotesPerMeasure).cgFloat
        return max(reservedWidth, visibleWidth)
    }

    // as an optimization, this could be defined as a lazy let getter
    var totalHeight: CGFloat {
        // - 1 because we're counting the spaces between ledger lines
        // 2 * Margin because we leave a little space above the top and bottom ledger lines
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        return staffHeight * numSpacesBetweenAllLines + 2 * DEFAULT_MARGIN_PTS
    }

    // deprecated. TODO remove in favor of frameSize
    var totalSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }

    var frameSize: CGSize {
        return totalSize
    }

    var stemLength: CGFloat {
        return 2 * staffHeight
    }

    var noteHeight: CGFloat {
        return staffHeight
    }

    var noteGeometry: NoteGeometry {
        return NoteGeometry(staffHeight: staffHeight)
    }

    var staffLines: [Line] {
        var lines = [Line]()
        for i in stride(from: 0, to: staffCount, by: 1) {
            let y = staffDrawStart + CGFloat(i) * staffHeight
            let start = CGPoint(x: 0, y: y)
            let end = CGPoint(x: totalWidth, y: y)
            lines.append(Line(start, end))
        }
        return lines
    }

    var ledgerLineGuides: [Line] {
        var arr = [Line]()
        for i in stride(from: 0, to: numLedgerLinesAbove, by: 1) {
            let y = DEFAULT_MARGIN_PTS + staffHeight * CGFloat(i)
            let start = CGPoint(x: 0, y: y)
            let end = CGPoint(x: totalWidth, y: y)
            arr.append(Line(start, end))
        }
        for i in stride(from: 0, to: numLedgerLinesBelow, by: 1) {
            let m = DEFAULT_MARGIN_PTS
            let numLinesAbovePlusNumStaffs = CGFloat(numLedgerLinesAbove + staffCount)
            let y = m + numLinesAbovePlusNumStaffs * staffHeight + staffHeight * CGFloat(i)
            let start = CGPoint(x: 0, y: y)
            let end = CGPoint(x: totalWidth, y: y)
            arr.append(Line(start, end))
        }
        return arr
    }

    func verticalGridlines(measure: MeasureViewModel) -> [Line] {
        let spacing = generateSpacing(measure: measure)
        let offsets = spacing.enumerated().map {spacing[0..<$0.0].reduce(0, +)}
        
        let lines = offsets.map { Line(CGPoint(x: $0, y: 0), CGPoint(x: $0, y: totalHeight))}
        return lines
    }
    
    func findSlot(slots: [CGFloat], position: CGFloat) -> Int {
        var pos = position
        for (index, element) in slots.enumerated() {
            pos -= element
            if pos < CGFloat(0) {
                return index
            }
        }
        
        return -1
    }

    func touchGuideRect(measure: MeasureViewModel,
                        location: CGPoint,
                        timeSignature: Rational) -> CGRect {

        let spacing = generateSpacing(measure: measure)
        let slot = findSlot(slots: spacing, position: location.x)
        
        let size = CGSize(width: spacing[slot], height: staffHeight)

        
        let originX = spacing[0..<slot].reduce(0, +)
        let originY = location.y - location.y.truncatingRemainder(dividingBy: heightOfSemitone) + DEFAULT_MARGIN_PTS  - size.height / 2

        let origin = CGPoint(x: originX, y: originY)

        return CGRect(origin: origin, size: size)
    }

    func touchRemainedInPosition(measure: MeasureViewModel,
                                 start: CGPoint,
                                 end: CGPoint) -> Bool {

        let startPos = pointToPositionInTime(measure: measure,
                                             x: start.x)
        let endPos = pointToPositionInTime(measure: measure,
                                           x: end.x)
        return startPos == endPos
    }

    func noteY(pitch: Int) -> CGFloat {
        return staffDrawStart + staffHeight * 2 - staffHeight / 2 * CGFloat(pitch) - noteHeight / 2
    }

    func noteX(spacing: [CGFloat], slot: Int) -> CGFloat {
        return spacing[0..<slot].reduce(0, +)
    }

    func noteStemEnd(pitch: Int, originY y: CGFloat) -> CGFloat {
        return pitch > 0 ? y + noteHeight + stemLength : y - stemLength
    }

    func pointToPitch(_ point: CGPoint) -> Int {
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        return Int(round(-(point.y - DEFAULT_MARGIN_PTS) / heightOfSemitone + numSpacesBetweenAllLines))
    }

    func pointToPositionInTime(measure: MeasureViewModel,
                               x: CGFloat) -> Rational {

        let numPositionsInTime = numGridSlots(timeSignature: measure.timeSignature)
        let spacing = generateSpacing(measure: measure)
        
        let slot = findSlot(slots: spacing, position: x)
        let slotWidth = Rational(Int(totalWidth)) / Rational(numPositionsInTime)
        let startSlot = spacing[0..<slot].reduce(0, +)
        
        let slotPercent = Rational(Int(x - startSlot)) / slotWidth
        let durationPerSlot = measure.timeSignature / Rational(numPositionsInTime)
        return (Rational(slot) + slotPercent) * durationPerSlot
    }

    private func numGridSlots(timeSignature: Rational) -> Int {
        return (timeSignature / state.selectedNoteDuration).intApprox
    }

    private func verticalGridlineSpacing(timeSignature: Rational) -> CGFloat {
        return totalWidth / CGFloat(numGridSlots(timeSignature: timeSignature))
    }
    
    func noteToSlot(position: Rational, timeSig: Rational) -> Int {
        let slots = Double(numGridSlots(timeSignature: timeSig))
        let percent = position / timeSig
        return Int(percent.double * slots)
    }
    
    func generateSpacing(measure: MeasureViewModel) -> [CGFloat] {
        let geometry = noteGeometry
        let timeSignature = measure.timeSignature
        var hasNotes = Set<Int>()
        
        var spacing = (0..<numGridSlots(timeSignature: timeSignature))
            .map {_ in verticalGridlineSpacing(timeSignature: timeSignature) }
        
        for note in measure.notes {
            let slot = noteToSlot(position: note.position, timeSig: timeSignature)
            let width = geometry.getBoundingBox(note: note).size.width
            
            if hasNotes.contains(slot) {
                spacing[slot] += width
            } else {
                spacing[slot] = max(width, spacing[slot])
                hasNotes.insert(slot)
            }
        }
        
        return spacing
    }
    
    func generateNoteX(measure: MeasureViewModel) -> [CGFloat] {
        let spacing = generateSpacing(measure: measure)
        let slots = measure.notes.map { noteToSlot(position: $0.position, timeSig: measure.timeSignature) }
        let groupedBySlot = measure.notes.categorize {noteToSlot(position: $0.position, timeSig: measure.timeSignature) }
        
        return slots.map { (slot: Int) -> CGFloat in
            let group = groupedBySlot[slot] ?? [NoteViewModel]()
            return spacing[slot] / CGFloat(group.count)
        }
    }
}

