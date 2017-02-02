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

    static let zero = MeasureGeometry(visibleSize: .zero)

    let visibleSize: CGSize // the only value that must be provided by client!
    let staffCount = 5
    let numLedgerLinesAbove = 4
    let numLedgerLinesBelow = 4
    let staffLineThickness: CGFloat = 2

    var frameSize: CGSize {
        return CGSize(width: visibleSize.width, height: totalHeight)
    }

    var staffDrawStart: CGFloat {
        return DEFAULT_MARGIN_PTS + CGFloat(numLedgerLinesAbove) * staffHeight
    }

    var staffHeight: CGFloat {
        return (visibleSize.height - 2 * DEFAULT_MARGIN_PTS) / CGFloat(staffCount + 1)
    }

    var totalHeight: CGFloat {
        // - 1 because we're counting the spaces between ledger lines
        // 2 * Margin because we leave a little space above the top and bottom ledger lines
        let numSpacesBetweenAllLines: CGFloat = CGFloat(staffCount + numLedgerLinesAbove + numLedgerLinesBelow - 1)
        return staffHeight * numSpacesBetweenAllLines + 2 * DEFAULT_MARGIN_PTS
    }

    var stemLength: CGFloat {
        return 2 * staffHeight
    }

    var noteHeight: CGFloat {
        return staffHeight
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

