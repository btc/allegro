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
    // Updated Letter to include String backing for cases when processing requires using a String
    enum Letter : String, CustomStringConvertible {
        case C = "C"
        case D = "D"
        case E = "E"
        case F = "F"
        case G = "G"
        case A = "A"
        case B = "B"

        var pitch: Int {
            switch self {
            case .C: return 0
            case .D: return 1
            case .E: return 2
            case .F: return 3
            case .G: return 4
            case .A: return 5
            case .B: return 6
            }
        }
        
        var description: String {
            switch self {
            case .C: return "C"
            case .D: return "D"
            case .E: return "E"
            case .F: return "F"
            case .G: return "G"
            case .A: return "A"
            case .B: return "B"
            }
        }
    }

    enum Accidental : Int {
        case doubleFlat = -2    // unicode ♭♭
        case flat = -1          // unicode ♭
        case natural = 0        // unicode ♮
        case sharp = 1          // unicode ♯
        case doubleSharp = 2    // unicode ♯♯
    }

    // Value represents the glyph that is drawn on screen, not the true duration of the note.
    // The true duration may be modified by dots or triplets, but the glyph is the same.
    // See https://en.wikipedia.org/wiki/Note_value
    enum Value: String {
        case whole = "whole"
        case half = "half"
        case quarter = "quarter"
        case eighth = "eighth"
        case sixteenth = "sixteenth"

        var nominalDuration: Rational {
            switch self {
            case .whole: return 1
            case .half: return 1/2
            case .quarter: return 1/4
            case .eighth: return 1/8
            case .sixteenth: return 1/16
            }
        }
        
        var hasFlag: Bool {
            switch self {
            case .whole, .half, .quarter:
                return false
            default:
                return true
            }
        }
    }
    
    // Gives the true duration of the note after modifiers
    var duration: Rational {
        return self.value.nominalDuration * self.dot.modifier
        // TODO (niklele) there will be a triplet modifier as well
    }
    
    // number of dots on the right of the note that extend the duration
    // See: https://en.wikipedia.org/wiki/Note_value#Modifiers
    enum Dot {
        case none
        case single
        case double
        
        // factor that is multiplied by the duration
        var modifier: Rational {
            switch self {
            case .none: return 1
            case .single: return 3/2
            case .double: return 7/4
            }
        }
    }

    let value: Value
    var dot: Dot
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
        self.dot = .none
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return  lhs.letter == rhs.letter &&
                lhs.octave == rhs.octave &&
                lhs.accidental == rhs.accidental &&
                lhs.duration == rhs.duration &&
                lhs.rest == rhs.rest
    }
}
