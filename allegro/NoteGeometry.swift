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
    
    let dotRadius = CGFloat(5)
    fileprivate let dotSpacing = CGFloat(10)
    
    var scale: CGFloat {
        return staffHeight / defaultNoteHeight
    }
    
    fileprivate var size: CGSize {
        return CGSize(width: defaultNoteWidth * scale, height: defaultNoteHeight * scale)
    }
    
    // origin of the note head in the parent coordinate frame
    var frame: CGRect {
        return CGRect(
            origin: origin,
            size: size
        )
    }
    
    init(staffHeight: CGFloat) {
        self.staffHeight = staffHeight
    }
    
    func getAccidentalFrame(note: NoteViewModel) -> CGRect {
        if !note.displayAccidental {
            return CGRect(origin: origin, size: .zero)
        }
        
        let center = CGPoint(x: origin.x,
                             y: origin.y + frame.size.width / 2)

        let info = note.accidental.infos

        let offset = info.1

        let size = CGSize(width: 50, height: 60)
        let accidentalOrigin = CGPoint(x: center.x - size.width / 2 + offset.x,
                             y: center.y - size.height / 2 + offset.y)

        return CGRect(origin: accidentalOrigin, size: size)
    }
    
    func getDotBoundingBox(note: NoteViewModel) -> CGRect {
        var centerY = origin.offset(dx: frame.size.width + dotSpacing, dy: frame.size.height / 4)
        if !note.onStaffLine {
            centerY = centerY.offset(dx: 0, dy: frame.size.height / 4)
        }
        let dotOrigin = centerY.offset(dx: 0, dy: -dotRadius)
        var dotWidth = CGFloat(0)
        
        switch note.dot {
        case .none: ()
        case .single:
            dotWidth = CGFloat(2) * dotRadius
        case .double:
            dotWidth = CGFloat(4) * dotRadius + dotSpacing
        }
        
        return CGRect(origin: dotOrigin, size: CGSize(width: dotWidth, height: 2 * dotRadius))
    }
    
    func getBoundingBox(note: NoteViewModel) -> CGRect {
        return frame.boundingBox(other: getAccidentalFrame(note: note)).boundingBox(other: getDotBoundingBox(note: note))
    }
}
