//
//  Tie.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class Tie: Equatable {
    // keep track of starting / ending note
    
    let start: Note
    let end: Note
    
    init(startNote: Note, endNote: Note) {
        self.start = startNote
        self.end = endNote
        startNote.tie = self
        endNote.tie = self
    }
    
    static func ==(lhs: Tie, rhs: Tie) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
