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
    enum Letter : Int {
        case C = 0
        case D = 1
        case E = 2
        case F = 3
        case G = 4
        case A = 5
        case B = 6
    }

    enum Accidental {
        case natural        // unicode ♮
        case sharp          // unicode ♯
        case flat           // unicode ♭
        case doubleSharp    // unicode ♯♯
        case doubleFlat     // unicode ♭♭
    }

    // Value represents the glyph that is drawn on screen, not the true duration of the note.
    // The true duration may be modified by dots or triplets, but the glyph is the same.
    // See https://en.wikipedia.org/wiki/Note_value
    enum Value: CustomStringConvertible {
        case whole, half, quarter, eighth, sixteenth, thirtysecond, sixtyfourth, onetwentyeighth, twofiftysixth

        var description: String {
            switch self {
            case .whole: return "1"
            case .half: return "1/2"
            case .quarter: return "1/4"
            case .eighth: return "1/8"
            case .sixteenth: return "1/16"
            case .thirtysecond: return "1/32"
            case .sixtyfourth: return "1/64"
            case .onetwentyeighth: return "1/128"
            case .twofiftysixth: return "1/256"
            }
        }
        var nominalDuration: Rational {
            switch self {
            case .whole: return 1
            case .half: return 1/2
            case .quarter: return 1/4
            case .eighth: return 1/8
            case .sixteenth: return 1/16
            case .thirtysecond: return 1/32
            case .sixtyfourth: return 1/64
            case .onetwentyeighth: return 1/128
            case .twofiftysixth: return 1/256
            }
        }
    }
    
    var duration: Rational {
        return self.value.nominalDuration * dotModifier
    }
    // TODO (niklele) there will be a triplet modifier as well
    
    // number of dots on the right of the note that extend the duration
    // See: https://en.wikipedia.org/wiki/Note_value#Modifiers
    enum Dot {
        case none, single, double
    }
    private var dotModifier: Rational = 1
    var dot: Dot {
        set(newDot) {
            switch newDot {
            case .none:
                dotModifier = 1
                self.dot = newDot
            case .single:
                dotModifier = 3/2
                self.dot = newDot
            case .double:
                dotModifier = 7/4
                self.dot = newDot
            }
        }
        get {
            return self.dot
        }
    }

    let value: Value
    let letter: Letter
    let octave: Int
    var accidental: Accidental
    var rest: Bool // true if the Note is a rest

    init(value: Value, letter: Letter, octave: Int, accidental: Accidental = .natural, rest: Bool = false) {
        self.value = value
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.rest = rest
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return  lhs.letter == rhs.letter &&
                lhs.octave == rhs.octave &&
                lhs.accidental == rhs.accidental &&
                lhs.duration == rhs.duration &&
                lhs.rest == rhs.rest
    }
}
