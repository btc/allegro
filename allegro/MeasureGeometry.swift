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

        let measure: MeasureViewModel
        let visibleSize: CGSize

        init(measure: MeasureViewModel, visibleSize: CGSize) {
            self.measure = measure
            self.visibleSize = visibleSize
        }
    }

    static let zero = MeasureGeometry(state: State(measure: MeasureViewModel(Measure()), visibleSize: .zero))

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

    // we're fixing totalWidth for now for testing purposes
    var totalWidth: CGFloat {
        let measure = state.measure
        guard measure.notes.count > 0 else { return state.visibleSize.width }
        
        let spacing = noteStartX
        var finalNoteEndspacing = spacing[spacing.count - 1]
        
        // the bbox can extend past the note frame itself for dots
        // which we don't have for now but in the future :)
        let bbox = noteGeometry.getBoundingBox(note: measure.notes[measure.notes.count - 1])
        finalNoteEndspacing += bbox.origin.x - noteGeometry.frame.origin.x
        finalNoteEndspacing += bbox.size.width
        
        return max(finalNoteEndspacing, state.visibleSize.width)
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

    // uh this doesn't really do anything but we'll just delete some time later
    func verticalGridlines(measure: MeasureViewModel) -> [Line] {
        let offsets = [CGFloat]()
        
        let lines = offsets.map { Line(CGPoint(x: $0, y: 0), CGPoint(x: $0, y: totalHeight))}
        return lines
    }
    
    func staffY(pitch: Int) -> CGFloat {
        return staffDrawStart + staffHeight * 2 - staffHeight / 2 * CGFloat(pitch)
    }

    func noteY(pitch: Int) -> CGFloat {
        return staffY(pitch: pitch) - noteHeight / 2
    }

    func noteX(position: Rational, timeSignature: Rational) -> CGFloat {
        return position.cgFloat / timeSignature.cgFloat * totalWidth
    }

    func noteStemEnd(pitch: Int, originY y: CGFloat) -> CGFloat {
        return pitch > 0 ? y + noteHeight + stemLength : y - stemLength
    }

    func pointToPitch(_ point: CGPoint) -> Int {
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        return Int(round(-(point.y - DEFAULT_MARGIN_PTS) / heightOfSemitone + numSpacesBetweenAllLines))
    }

    func pointToPositionInTime(x: CGFloat) -> Rational {
        let measure = state.measure
        var notesCenterX = noteStartX.map { $0 + noteGeometry.frame.size.width / 2 }
        notesCenterX.insert(0, at: 0)
        notesCenterX.append(totalWidth)
        
        var positions = measure.notes.map { $0.position }
        positions.insert(Rational(0), at: 0)
        positions.append(measure.timeSignature)
        
        let findIndex = notesCenterX.index { x < $0 }
        guard let noteAfterIndex = findIndex else { return Rational(0) }
        guard noteAfterIndex != 0 else { return Rational(0) }
        
        let noteBeforeX = notesCenterX[noteAfterIndex - 1]
        let noteBeforeTime = positions[noteAfterIndex - 1]
        
        let noteAfterX = notesCenterX[noteAfterIndex]
        let noteAfterTime = positions[noteAfterIndex]
        
        let intervalSize = noteAfterX - noteBeforeX
        let inside = Rational(Int(x - noteBeforeX), Int(intervalSize))
        
        guard let percentInside = inside else { return noteBeforeTime }
        let output = noteBeforeTime + percentInside * (noteAfterTime - noteBeforeTime)
        return output.lowestTerms
    }

    typealias Interval = (start: CGFloat, end: CGFloat)
    
    var noteStartX: [CGFloat] {
        get {
            let measure = state.measure
            
            // whitespace is the region between the notes that are not covered by the bounding boxes
            var whitespace = [Interval]()
            var blackspace = [Interval]()
            
            var totalBlackspace = CGFloat(0)
            let defaultWidth = state.visibleSize.width
            
            guard measure.notes.count > 0 else { return [CGFloat]() }
            let g = noteGeometry
            var last = CGFloat(0)
            
            // Calculate the whitespace intervals between notes if there are any
            // Also merges consecutive notes into contiguous interval
            for note in measure.notes {
                let noteCenterX = defaultWidth * note.position.cgFloat / measure.timeSignature.cgFloat
                let bbox = g.getBoundingBox(note: note)
                
                let defaultX = max(last,noteCenterX - bbox.size.width / 2)
                whitespace.append(Interval(last, defaultX))
                blackspace.append(Interval(defaultX, defaultX + bbox.width))
                
                last = defaultX + bbox.width
                totalBlackspace += bbox.width
            }
            
            // add the whitespace after the last note
            if last < defaultWidth {
                whitespace.append(Interval(last, defaultWidth))
            }
            
            let totalWhitespace = whitespace.reduce(0) {$0 + $1.end - $1.start}
            
            if totalWhitespace > 0 && totalBlackspace < defaultWidth {
                let whitespaceScaling = (defaultWidth - totalBlackspace) / totalWhitespace
                
                var whitespaceBefore = CGFloat(0)
                
                for (i, space) in whitespace.enumerated() {
                    let diff = (space.end - space.start) * whitespaceScaling
                    let start = whitespaceBefore
                    let end = space.start + diff
                    
                    whitespaceBefore += diff
                    whitespace[i] = Interval(start, end)
                }
                
                blackspace = zip(whitespace, blackspace).map {
                    Interval(
                        $0.end,
                        $0.end + $1.end - $1.start
                    )
                }
            }
            
            // right now blackspace includes the necessary space for an accidental if it exists
            // we now remove that to get the start position of the note frame by itself
            let startX = zip(blackspace, measure.notes).map {
                $0.start + g.frame.origin.x - g.getBoundingBox(note: $1).origin.x
            }
            
            return startX
        }
    }
}

