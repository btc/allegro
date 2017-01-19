//
//  Note.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

struct Note {
    // TODO pitch (see #42)
    // TODO duration (see #37)
    
    enum Accidental {
        case natural    // unicode ♮
        case sharp      // unicode ♯
        case flat       // unicode ♭
    }
    let accidental: Note.Accidental
    
    // true if the Note is a rest
    let rest: Bool
    
    init(accidental: Note.Accidental = .natural, rest: Bool = false) {
        self.accidental = accidental
        self.rest = rest
    }
}
