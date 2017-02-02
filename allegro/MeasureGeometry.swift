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

    static let zero = MeasureGeometry(visibleSize: .zero)

    let visibleSize: CGSize // the only value that must be provided by client!
    let staffCount = 5
    let numLedgerLinesAbove = 4
    let numLedgerLinesBelow = 4

    var frameSize: CGSize {
        return CGSize(width: visibleSize.width, height: totalHeight)
    }

    var staffDrawStart: CGFloat {
        return DEFAULT_MARGIN_PTS + CGFloat(numLedgerLinesAbove) * staffHeight
    }

    var staffHeight: CGFloat {
        return (visibleSize.height - 2 * DEFAULT_MARGIN_PTS) / CGFloat(staffCount + 1)
    }

    // it's a lot easier to compute width than height, so they are provided independently to allow clients to minimize
    // arithmetic operations

    var totalWidth: CGFloat {
        return visibleSize.width // TODO(btc): handle warping/stretching of space in the x-axis

    }

    var totalHeight: CGFloat {
        // - 1 because we're counting the spaces between ledger lines
        // 2 * Margin because we leave a little space above the top and bottom ledger lines
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        return staffHeight * numSpacesBetweenAllLines + 2 * DEFAULT_MARGIN_PTS
    }

    var totalSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }

    var stemLength: CGFloat {
        return 2 * staffHeight
    }

    var noteHeight: CGFloat {
        return staffHeight
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

    func verticalGridlines(timeSignature: Rational, noteDuration: Rational) -> [Line] {

        var arr = [Line]()

        let numGridSlots = timeSignature / noteDuration // spaces between fence posts
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
        return position.cgFloat / timeSignature.cgFloat * visibleSize.width
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
                               noteDuration: Rational) -> Rational? {

        let numPositionsInTime = timeSignature / noteDuration
        let ratioOfScreenWidth = x / visibleSize.width
        let positionInTime = Int(ratioOfScreenWidth * numPositionsInTime.cgFloat)
        return Rational(positionInTime) / numPositionsInTime * timeSignature
    }
}

