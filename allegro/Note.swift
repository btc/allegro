//
//  Note.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class Note {
    // Quick n dirty pitch for now.
    // 0 is the center of the bars.
    // Every increment by 1 moves up half staff height
    // -1 moves it down
    var pitch = 0
    
    init(pitch: Int) {
        self.pitch = pitch
    }
}
