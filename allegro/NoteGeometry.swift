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
    
    // origin of the note head in the parent coordinate frame
    func getFrame(origin: CGPoint) -> CGRect {
        return CGRect(
            origin: origin,
            size: CGSize(width: defaultNoteWidth * scale, height: defaultNoteHeight * scale)
        )
    }
    
    func getAccidentalFrame(noteFrame: CGRect) -> CGRect {
        
    }
}
