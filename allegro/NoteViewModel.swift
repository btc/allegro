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
            // +1 is because we're counting from C5 but we want the center at B4
            return note.letter.rawValue - 7 * (5 - note.octave) + 1
        }
    }

    init(note: Note) {
        self.note = note
    }
}
