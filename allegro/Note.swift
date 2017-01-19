//
//  Note.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//


class Note {

    // The pitch is decomposed into the letter, octave, and accidental
    // Octave is a # indicating where the note lies on a piano or a staff
    // Accidentals are semitone modifiers that do not affect the vertical placement of the note on the staff
    // See #42 for more information
    enum Letter {
        case A, B, C, D, E, F, G
    }
    let letter: Letter
    
    let octave: Int
    
    enum Accidental {
        case natural        // unicode ♮
        case sharp          // unicode ♯
        case flat           // unicode ♭
        case doubleSharp    // unicode ♯♯
        case doubleFlat     // unicode ♭♭
    }
    let accidental: Note.Accidental
    
    // TODO duration (see #37)
    
    // true if the Note is a rest
    let rest: Bool
    
    init(letter: Letter, octave: Int, accidental: Note.Accidental = .natural, rest: Bool = false) {
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.rest = rest
    }
    
}
