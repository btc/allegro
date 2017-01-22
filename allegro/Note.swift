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

        // TODO: reformat into 1/1 1/2 format
        var description: String {
            switch self {
            case .whole: return "1"
            case .half: return "2"
            case .quarter: return "4"
            case .eighth: return "8"
            case .sixteenth: return "16"
            case .thirtysecond: return "32"
            case .sixtyfourth: return "64"
            case .onetwentyeighth: return "128"
            case .twofiftysixth: return "256"
            }
        }

        var rational: Rational {
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

    let letter: Letter
    let octave: Int
    let accidental: Accidental
    let duration: Duration
    let rest: Bool // true if the Note is a rest



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
