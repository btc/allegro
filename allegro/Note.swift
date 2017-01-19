//
//  Note.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

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
    
    enum Value {
        case whole, half, quarter, eighth, sixteenth
    }
    
    let value: Value
    
    // TODO can we remove the "!"s? Rational probably has it in case of divide by 0
    func getDuration() -> Rational {
        switch self.value {
        case .whole:
            return Rational(1)
        case .half:
            return Rational(1,2)!
        case .quarter:
            return Rational(1,4)!
        case .eighth:
            return Rational(1,8)!
        case .sixteenth:
            return Rational(1,16)!
        }
    }
    
    // true if the Note is a rest
    let rest: Bool
    
    init(value: Value, letter: Letter, octave: Int, accidental: Note.Accidental = .natural, rest: Bool = false) {
        self.value = value
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.rest = rest
    }
    
}
