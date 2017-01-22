//
//  NoteViewModel.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/19/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation

struct NoteViewModel {

    let note: Note
    
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

    static func pitchToLetterAndOffset(pitch: Int) -> (Note.Letter, Int) {
        return (.G, 5) // TODO(btc): Someone who understands this, please implement
    }

    init(note: Note) {
        self.note = note
    }
}
