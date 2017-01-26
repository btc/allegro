//
//  Mocks.swift
//  allegro
//
//  Created by Nikhil Lele on 1/23/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

func mockPart(name: String) -> Part {
    let part = Part()
    
    switch name {
    case "CMajor":
        // measure 1
        _ = part.insert(note: Note(duration: .quarter, letter: .C, octave: 4), intoMeasureIndex: 0, at: 0)
        _ = part.insert(note: Note(duration: .quarter, letter: .E, octave: 4), intoMeasureIndex: 0, at: 1/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .G, octave: 4), intoMeasureIndex: 0, at: 2/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .C, octave: 5), intoMeasureIndex: 0, at: 3/4)
        part.extend()
        
        // measure 2
        _ = part.insert(note: Note(duration: .quarter, letter: .C, octave: 5), intoMeasureIndex: 1, at: 0)
        _ = part.insert(note: Note(duration: .quarter, letter: .G, octave: 4), intoMeasureIndex: 1, at: 1/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .E, octave: 4), intoMeasureIndex: 1, at: 2/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .C, octave: 4), intoMeasureIndex: 1, at: 3/4)
        part.extend()
        
        // measure 3
        _ = part.insert(note: Note(duration: .eighth, letter: .C, octave: 4), intoMeasureIndex: 2, at: 0)
        _ = part.insert(note: Note(duration: .eighth, letter: .E, octave: 4), intoMeasureIndex: 2, at: 1/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .G, octave: 4), intoMeasureIndex: 2, at: 2/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .C, octave: 5), intoMeasureIndex: 2, at: 3/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .C, octave: 5), intoMeasureIndex: 2, at: 4/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .G, octave: 4), intoMeasureIndex: 2, at: 5/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .E, octave: 4), intoMeasureIndex: 2, at: 6/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .C, octave: 4), intoMeasureIndex: 2, at: 7/8)
        
    case "DMajor":
        // measure 1
        _ = part.insert(note: Note(duration: .quarter, letter: .D, octave: 4), intoMeasureIndex: 0, at: 0)
        _ = part.insert(note: Note(duration: .quarter, letter: .F, octave: 4, accidental: .sharp), intoMeasureIndex: 0, at: 1/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .A, octave: 4), intoMeasureIndex: 0, at: 2/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .D, octave: 5), intoMeasureIndex: 0, at: 3/4)
        part.extend()
        
        // measure 2
        _ = part.insert(note: Note(duration: .quarter, letter: .D, octave: 5), intoMeasureIndex: 1, at: 0)
        _ = part.insert(note: Note(duration: .quarter, letter: .F, octave: 4, accidental: .sharp), intoMeasureIndex: 1, at: 1/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .A, octave: 4), intoMeasureIndex: 1, at: 2/4)
        _ = part.insert(note: Note(duration: .quarter, letter: .D, octave: 4), intoMeasureIndex: 1, at: 3/4)
        _ = part.extend()
        
        // measure 3
        _ = part.insert(note: Note(duration: .eighth, letter: .D, octave: 4), intoMeasureIndex: 2, at: 0)
        _ = part.insert(note: Note(duration: .eighth, letter: .F, octave: 4, accidental: .sharp), intoMeasureIndex: 2, at: 1/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .A, octave: 4), intoMeasureIndex: 2, at: 2/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .D, octave: 5), intoMeasureIndex: 2, at: 3/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .D, octave: 5), intoMeasureIndex: 2, at: 4/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .A, octave: 4, accidental: .sharp), intoMeasureIndex: 2, at: 5/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .F, octave: 4), intoMeasureIndex: 2, at: 6/8)
        _ = part.insert(note: Note(duration: .eighth, letter: .D, octave: 4), intoMeasureIndex: 2, at: 7/8)
        
    default:
        _ = part.insert(note: Note(duration: .whole, letter: .C, octave: 4), intoMeasureIndex: 0, at: 0)
    }
    
    return part
}
