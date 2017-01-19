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
    
    // 0 is the center of the bars.
    // Every increment by 1 moves up half staff height
    // -1 moves it down
    var pitch: Int {
        get {
            return Int(arc4random_uniform(6)) - 3 // TODO translate note's pitch for ease of use in UI
        }
    }

    init(note: Note) {
        self.note = note
    }
}
