//
//  Mocks.swift
//  allegro
//
//  Created by Nikhil Lele on 1/23/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

func mockPart(name: String) -> Part {
    var part = Part()
    
    part.insert(note: Note(duration: .quarter, letter: .C, octave: 4), intoMeasureIndex: 0, at: 0)
    
    return part
}
