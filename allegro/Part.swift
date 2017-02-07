//
//  Part.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

class Part {
    
    // beats per minute (bpm) eg. 120
    var tempo: Int = 120
    
    var composer: String = ""
    var title: String = ""
    var comment: String = ""

    // ordered list of measures in the piece
    private(set) var measures: [Measure] = [Measure]()
    
    // initialize with 1 empty measure
    init() {
        extend()
    }

    func extend() {
        let timeSigForNewMeasure = measures.last?.timeSignature ?? Measure.defaultTimeSignature
        measures.append(Measure(time: timeSigForNewMeasure))
    }

    func insert(note: Note, intoMeasureIndex i: Int, at position: Rational) -> Bool {
        guard measures.indices.contains(i) else { return false }
        return measures[i].insert(note: note, at: position)
    }

    func removeNote(fromMeasureIndex i: Int, at position: Rational) -> Bool {
        guard measures.indices.contains(i) else { return false }
        // TODO(btc): remove note
        return measures[i].removeNote(at: position)
    }
    
    // Adds the note to first freespace of any measure available.
    // If it doesn't fit, the next free space is tried, then a new measure is created
    // If the note's duration is longer than the time signature, the note is not added
    func appendNote(note: Note) {
        var i = 0 // measure index
        while true {

            let m = measures[i]

            // check against time signature to prevent endless loop from bad input
            if note.duration > m.timeSignature {
                return
            }
            
            for (pos, duration) in m.getFree() {
                if note.duration <= duration {
                    // add note
                    if insert(note: note, intoMeasureIndex: i, at: pos) == true {
                        return
                    }
                }
            }
            // no free space found in this measure
            i += 1

            // extend when we've run out of measures
            if i >= measures.count {
                extend()
            }
        }
    }
    
    //Setters for time signatures
    func setTimeSignature(timeSignature: Rational) {
        for i in 0..<measures.count {
            measures[i].timeSignature = timeSignature
        }
    }
    
    func setKeySignature(keySignature: Key) {
        for i in 0..<measures.count {
            measures[i].key = keySignature
        }
    }
}
