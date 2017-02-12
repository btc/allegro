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
    
    fileprivate let defaultNoteWidth = CGFloat(70)
    fileprivate let defaultNoteHeight = CGFloat(55.16665)
    
    var scale: CGFloat {
        return staffHeight / defaultNoteHeight
    }
    
    func getSize() -> CGSize {
        return CGSize(width: defaultNoteWidth * scale, height: defaultNoteHeight * scale)
    }
    
    // origin of the note head in the parent coordinate frame
    func getFrame(origin: CGPoint) -> CGRect {
        return CGRect(
            origin: origin,
            size: getSize()
        )
    }
    
    func getAccidentalFrame(origin: CGPoint, note: NoteViewModel) -> CGRect {
        guard note.displayAccidental else {
            return CGRect(origin: origin, size: .zero)
        }
        
        let noteFrame = getFrame(origin: origin)
        
        let center = CGPoint(x: origin.x,
                             y: origin.y + noteFrame.size.width / 2)

        let info = note.accidental.infos

        let offset = info.1

        let size = CGSize(width: 50, height: 60)
        let origin = CGPoint(x: center.x - size.width / 2 + offset.x,
                             y: center.y - size.height / 2 + offset.y)

        return CGRect(origin: origin, size: size)
    }
    
    func getBoundingBox(origin: CGPoint, note: NoteViewModel) -> CGRect {
        let originFrame = getFrame(origin: origin)
        return originFrame.boundingBox(other: getAccidentalFrame(origin: origin, note: note))
    }
    

}
