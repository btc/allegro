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
    
    let margin = CGFloat(30)

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
        finalNoteEndspacing += bbox.size.width
        finalNoteEndspacing += margin
        
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
        if staffHeight < 30 { return arr }
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
        var notesCenterX = zip(noteStartX, measure.notes).map { $0 + noteGeometry.getFrame(note: $1).size.width / 2 }
        notesCenterX.insert(0, at: 0)
        notesCenterX.append(totalWidth)
        
        var positions = measure.notes.map { $0.position }
        positions.insert(Rational(0), at: 0)
        positions.append(measure.timeSignature)
        
        let findIndex = notesCenterX.index { x < $0 }
        guard let noteAfterIndex = findIndex else { return Rational(0) }
        guard noteAfterIndex != 0 else { return Rational(0) }
        
        let noteBeforeX = notesCenterX[noteAfterIndex - 1]
        let noteBeforeTime = positions[noteAfterIndex - 1].cgFloat
        
        let noteAfterX = notesCenterX[noteAfterIndex]
        let noteAfterTime = positions[noteAfterIndex].cgFloat
        
        let intervalSize = noteAfterX - noteBeforeX
        let percentInside = CGFloat((x - noteBeforeX) / intervalSize)
        
        let output = noteBeforeTime + percentInside * (noteAfterTime - noteBeforeTime)
        return output.round(denom: 1000)
    }

    typealias Interval = (start: CGFloat, end: CGFloat)
    
    var noteStartX: [CGFloat] {
        get {
            let measure = state.measure
            
            // whitespace is the region between the notes that are not covered by the bounding boxes
            var whitespace = [Interval]()
            var blackspace = [Interval]()
            
            var totalBlackspace = CGFloat(0)
            let defaultWidth = state.visibleSize.width - 2 * margin
            
            guard measure.notes.count > 0 else { return [CGFloat]() }
            let g = noteGeometry
            var last = margin
            
            // Calculate the whitespace intervals between notes if there are any
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
            if last - margin < defaultWidth {
                whitespace.append(Interval(last, defaultWidth + margin))
            }
            
            let totalWhitespace = whitespace.reduce(0) {$0 + $1.end - $1.start}
            
            if totalWhitespace > 0 && totalBlackspace < defaultWidth {
                let whitespaceScaling = (defaultWidth - totalBlackspace) / totalWhitespace
                
                var whitespaceBefore = margin
                var blackspaceBefore = CGFloat(0)
                
                for (i, space) in whitespace.enumerated() {
                    let diff = (space.end - space.start) * whitespaceScaling
                    let start = whitespaceBefore + blackspaceBefore
                    let end = start + diff
                    
                    whitespace[i] = Interval(start, end)
                    
                    whitespaceBefore += diff
                    
                    if i < blackspace.count {
                        blackspaceBefore += blackspace[i].end - blackspace[i].start
                    }
                }
                
                blackspace = zip(whitespace, blackspace).map {
                    Interval(
                        $0.end,
                        $0.end + $1.end - $1.start
                    )
                }
            } else {
                // even if we shrink all the notes we can't fit all of them in
                // so we remove all the whitespace
                var blackspaceBefore = CGFloat(margin)
                for (i, space) in blackspace.enumerated() {
                    let start = blackspaceBefore
                    let end = start + space.end - space.start
                    blackspace[i] = Interval(start, end)
                    
                    blackspaceBefore += space.end - space.start
                }
            }
            
            // right now blackspace includes the necessary space for an accidental if it exists
            // we now remove that to get the start position of the note frame by itself
            let startX = zip(blackspace, measure.notes).map {
                $0.start + g.getFrame(note: $1).origin.x - g.getBoundingBox(note: $1).origin.x
            }
            
            return startX
        }
    }
}

