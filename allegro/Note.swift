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

    enum Accidental {
        case natural        // unicode ♮
        case sharp          // unicode ♯
        case flat           // unicode ♭
        case doubleSharp    // unicode ♯♯
        case doubleFlat     // unicode ♭♭
    }

    enum Value {
        case whole, half, quarter, eighth, sixteenth
    }

    let letter: Letter
    let octave: Int
    let accidental: Accidental
    let value: Value
    let rest: Bool // true if the Note is a rest

    var duration: Rational {
        switch value {
        case .whole:
            return 1
        case .half:
            return 1/2
        case .quarter:
            return 1/4
        case .eighth:
            return 1/8
        case .sixteenth:
            return 1/16
        }
    }

    init(value: Value, letter: Letter, octave: Int, accidental: Accidental = .natural, rest: Bool = false) {
        self.value = value
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.rest = rest
    }

    static func range(from startLetter: Letter, _ startOctave: Int, to endLetter: Letter, _ endOctave: Int) -> [Note] {
        return [] // TODO
    }
}
