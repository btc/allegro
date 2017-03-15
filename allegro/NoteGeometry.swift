//
//  NoteGeometry.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/2/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

struct NoteGeometry {
    let staffHeight: CGFloat
    var origin = CGPoint.zero
    
    fileprivate let defaultNoteWidth = CGFloat(70)
    fileprivate let defaultNoteHeight = CGFloat(55.16665)
    
    var dotRadius: CGFloat {
        return CGFloat(scale * 5)
    }
    
    var dotSpacing: CGFloat {
        return CGFloat(scale * 10)
    }
    
    var scale: CGFloat {
        return staffHeight / defaultNoteHeight
    }
    
    fileprivate var size: CGSize {
        return CGSize(width: defaultNoteWidth * scale, height: defaultNoteHeight * scale)
    }
    
    
    let restBoxWidth = CGFloat(30)
    let restSizeDict = [
        Note.Value.whole: CGSize(width: 60, height: 10),
        Note.Value.half: CGSize(width: 60, height: 10),
        Note.Value.quarter: CGSize(width: 40, height: 125),
        Note.Value.eighth: CGSize(width: 80, height: 160),
        Note.Value.sixteenth: CGSize(width: 80, height: 240)
    ]
    
    var sixteenthSecondImageOffset: CGPoint {
        return CGPoint(x: -14.5 * scale, y: 45 * scale)
    }
    
    func getRestSize(value: Note.Value) -> CGSize {
        guard let unscaledSize = restSizeDict[value] else { return CGSize.zero }
        return CGSize(width: unscaledSize.width * scale, height: unscaledSize.height * scale)
    }
    
    init(staffHeight: CGFloat) {
        self.staffHeight = staffHeight
    }
    
    func getAccidentalFrame(note: NoteViewModel) -> CGRect {
        let frame = getFrame(note: note)
        if !note.displayAccidental {
            return CGRect(origin: origin, size: .zero)
        }
        
        let center = CGPoint(x: origin.x,
                             y: origin.y + frame.size.width / 2)

        let info = note.note.accidental.infos

        let offset = info.1

        let size = CGSize(width: 50, height: 60)
        let accidentalOrigin = CGPoint(x: center.x - size.width / 2 + offset.x,
                             y: center.y - size.height / 2 + offset.y)

        return CGRect(origin: accidentalOrigin, size: size)
    }
    
    
    func getFrame(note: NoteViewModel) -> CGRect {
        if note.note.rest {
            let size = getRestSize(value: note.note.value)
            return CGRect(origin: origin, size: size)
        }
        
        return CGRect(
            origin: origin,
            size: size
        )
    }
    
    func getDotBoundingBox(note: NoteViewModel) -> CGRect {
        let frame = getFrame(note: note)
        var centerY = origin.offset(dx: frame.size.width + dotSpacing, dy: frame.size.height / 4)
        if !note.onStaffLine {
            centerY = centerY.offset(dx: 0, dy: frame.size.height / 4)
        }
        let dotOrigin = centerY.offset(dx: 0, dy: -dotRadius)
        var dotWidth = CGFloat(0)
        
        switch note.note.dot {
        case .none: ()
        case .single:
            dotWidth = CGFloat(2) * dotRadius
        case .double:
            dotWidth = CGFloat(4) * dotRadius + dotSpacing
        }
        
        return CGRect(origin: dotOrigin, size: CGSize(width: dotWidth, height: 2 * dotRadius))
    }
    
    func getBoundingBox(note: NoteViewModel) -> CGRect {
        return getFrame(note: note).boundingBox(other: getAccidentalFrame(note: note)).boundingBox(other: getDotBoundingBox(note: note))
    }
}
