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

    func verticalGridlines(timeSignature: Rational, selectedNoteDuration: Rational) -> [Line] {

        var arr = [Line]()

        let numGridSlots = timeSignature / selectedNoteDuration // spaces between fence posts
        let numGridlines: Int = numGridSlots.intApprox - 1 // number of fence posts. we ignore the two end posts.

        // right now, grid lines are evenly-spaced. this will no longer be true once we expand the grid slots to
        // provide more physical space to notes of shorter durations. 
        // Remember, we're going to enforce a minimum slot size and right here is where it's going to happen.

        let gridlineOffset = totalWidth / numGridSlots.cgFloat

        for i in stride(from: 0, to: numGridlines, by: 1) {

            let x = gridlineOffset * CGFloat(i + 1)
            let start = CGPoint(x: x, y: 0)
            let end = CGPoint(x: x, y: totalHeight)
            arr.append(Line(start, end))
        }
        return arr
    }

    func noteY(pitch: Int) -> CGFloat {
        return staffDrawStart + staffHeight * 2 - staffHeight / 2 * CGFloat(pitch) - noteHeight / 2
    }

    func noteX(position: Rational, timeSignature: Rational) -> CGFloat {
        return position.cgFloat / timeSignature.cgFloat * totalWidth
    }

    func noteStemEnd(pitch: Int, originY y: CGFloat) -> CGFloat {
        return pitch > 0 ? y + noteHeight + stemLength : y - stemLength
    }

    func pointToPitch(_ point: CGPoint) -> Int {
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        let lengthOfSemitoneInPoints = staffHeight / 2
        return Int(round(-(point.y - DEFAULT_MARGIN_PTS) / lengthOfSemitoneInPoints + numSpacesBetweenAllLines))
    }

    func pointToPositionInTime(x: CGFloat,
                               timeSignature: Rational,
                               noteDuration: Rational) -> Rational {

        let numPositionsInTime = timeSignature / noteDuration
        let ratioOfScreenWidth = x / totalWidth
        let positionInTime = Int(ratioOfScreenWidth * numPositionsInTime.cgFloat)
        return Rational(positionInTime) / numPositionsInTime * timeSignature
    }
}

