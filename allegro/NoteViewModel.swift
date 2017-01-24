//
//  NoteViewModel.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/19/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import Rational

struct NoteViewModel {

    let note: Note

    let position: Rational
    
    // 0 is the center of the bars (B4 in treble clef)
    // Every increment by 1 moves up half staff height
    // -1 moves it down
    var pitch: Int {
        get {
            // the number of notes away this note is from octave 5
            // 5 is the center, and 7 is the total number of notes (ABCDEFG)
            let octaveDiff = 7 * (5 - note.octave)
            
            // +1 is because we're counting from C5 but we want the center at B4
            return note.letter.rawValue - octaveDiff + 1
        }
    }

    static func pitchToLetterAndOffset(pitch: Int) -> (letter: Note.Letter, octave: Int) {
        // there is a way to do this using floor, but it is harder to understand
        var octave: Int
        switch pitch {
        case -26 ... -20:
            octave = 1
        case -19 ... -13:
            octave = 2
        case -12 ... -7:
            octave = 3
        case -6 ... 0:
            octave = 4
        case 1 ... 7:
            octave = 5
        case 8 ... 14:
            octave = 6
        case 15 ... 21:
            octave = 7
        case 22 ... 28:
            octave = 8
        default:
            octave = 4
        }
        
        // inverse of the function to get pitch
        var letter: Note.Letter
        switch pitch {
        case -20, -13, -6, 1, 8, 15:
            letter = .C
        case -19, -12, -5, 2, 9, 16:
            letter = .D
        case -18, -11, -4, 3, 10, 17:
            letter = .E
        case -17, -10, -3, 4, 11, 18:
            letter = .F
        case -16, -9, -2, 5, 12, 19:
            letter = .G
        case -15, -8, -1, 6, 13, 20:
            letter = .A
        case -21, -14, -7, 0, 7, 14:
            letter = .B
        default:
            letter = .C
        }
        return (letter, octave)
    }

    init(note: Note, position: Rational = 0) {
        self.note = note
        self.position = position
    }
}
