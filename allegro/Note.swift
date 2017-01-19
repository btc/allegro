//
//  Note.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//


class Note {

    // TODO pitch (see #42)
    /* Pitch is composed of a letter and an octave # indicating where the pitch lands (on a piano or staff) 
        see #42 for more information.
     */
    struct Pitch {
        enum Letter {
            case A, B, C, D, E, F, G
        }
        let octave: Int
        let letter: Letter
    }
    
    // TODO duration (see #37)
    
    enum Accidental {
        case natural        // unicode ♮
        case sharp          // unicode ♯
        case flat           // unicode ♭
        case doubleSharp    // unicode ♯♯
        case doubleFlat     // unicode ♭♭
    }
    let accidental: Note.Accidental
    
    // true if the Note is a rest
    let rest: Bool
    
    init(accidental: Note.Accidental = .natural, rest: Bool = false) {
        self.accidental = accidental
        self.rest = rest
    }
}
