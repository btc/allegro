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
    enum Letter {
        case A, B, C, D, E, F, G
    }

    enum Accidental: CustomStringConvertible {
        case doubleFlat     // unicode ♭♭
        case flat           // unicode ♭
        case natural        // unicode ♮
        case sharp          // unicode ♯
        case doubleSharp    // unicode ♯♯

        var description: String {
            switch self {
            case .doubleFlat: return "double flat"
            case .flat: return "flat"
            case .natural: return "natural"
            case .sharp: return "sharp"
            case .doubleSharp: return "double sharp"
            }
        }
    }


    // Value represents the glyph that is drawn on screen, not the true duration of the note.
    // The true duration may be modified by dots or triplets, but the glyph is the same.
    // See https://en.wikipedia.org/wiki/Note_value
    enum Value {
        case whole, half, quarter, eighth, sixteenth

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
        guard self.triplet != nil
            else { return self.value.nominalDuration * self.dot.modifier }
        if let tripletModifier = self.triplet?.modifier {
            return self.value.nominalDuration * tripletModifier
        } else {
            return self.value.nominalDuration * self.dot.modifier
        }
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
    var letter: Letter
    var octave: Int
    var accidental: Accidental
    var rest: Bool // true if the Note is a rest
    weak var tie: Tie? // holds a reference to a Tie if this Note belongs to one
    weak var triplet: Triplet? // holds a reference to a Triplet if this Note belongs to one

    init(value: Value, letter: Letter, octave: Int, accidental: Accidental = .natural, rest: Bool = false, tie: Tie? = nil, triplet: Triplet? = nil) {
        self.value = value
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.rest = rest
        self.dot = .none
        self.tie = tie
        self.triplet = triplet
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return  lhs.letter == rhs.letter &&
                lhs.octave == rhs.octave &&
                lhs.accidental == rhs.accidental &&
                lhs.duration == rhs.duration &&
                lhs.rest == rhs.rest
    }
}
