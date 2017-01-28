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

    enum Duration: CustomStringConvertible {
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
    }
    
    var durationRational: Rational {
        get {
            switch duration {
            case .whole: return 1 * dotModifier
            case .half: return 1/2 * dotModifier
            case .quarter: return 1/4 * dotModifier
            case .eighth: return 1/8 * dotModifier
            case .sixteenth: return 1/16 * dotModifier
            case .thirtysecond: return 1/32 * dotModifier
            case .sixtyfourth: return 1/64 * dotModifier
            case .onetwentyeighth: return 1/128 * dotModifier
            case .twofiftysixth: return 1/256 * dotModifier
            }
        }
    }
    
    enum Dot {
        case none, single, double
    }
    
    private var dotModifier: Rational = 1
    // TODO (niklele) there will be a triplet modifier as well
    
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

    let letter: Letter
    let octave: Int
    var accidental: Accidental
    let duration: Duration
    var rest: Bool // true if the Note is a rest

    init(duration: Duration, letter: Letter, octave: Int, accidental: Accidental = .natural, rest: Bool = false) {
        self.duration = duration
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.rest = rest
    }

    static func range(from startLetter: Letter, _ startOctave: Int, to endLetter: Letter, _ endOctave: Int) -> [Note] {
        return [] // TODO
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return  lhs.letter == rhs.letter &&
                lhs.octave == rhs.octave &&
                lhs.accidental == rhs.accidental &&
                lhs.duration == rhs.duration &&
                lhs.rest == rhs.rest
    }
}
