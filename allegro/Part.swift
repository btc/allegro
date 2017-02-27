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
        measures.append(Measure(timeSignature: timeSigForNewMeasure))
    }

    // overwrite a measure with another
    func setMeasure(measureIndex: Int, measure: Measure) {
        guard measures.indices.contains(measureIndex) else { return }
        measures[measureIndex] = measure
    }

    func insert(note: Note, intoMeasureIndex i: Int, at position: Rational) -> Rational? {
        guard measures.indices.contains(i) else { return nil }
        return measures[i].insert(note: note, at: position)
    }

    func removeNote(fromMeasureIndex i: Int, at position: Rational) -> Bool {
        guard measures.indices.contains(i) else { return false }
        // TODO(btc): remove note
        return measures[i].removeNote(at: position)
    }

    func dotNote(at position: Rational, dot: Note.Dot, atMeasureIndex i: Int) -> Bool {
        guard measures.indices.contains(i) else { return false }
        return measures[i].dotNote(at: position, dot: dot)
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
            
            for free in m.frees {
                let pos = free.pos
                let duration = free.duration
                if note.duration <= duration {
                    // add note
                    if insert(note: note, intoMeasureIndex: i, at: pos) != nil {
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
    
    var timeSignature: Rational {
        return measures[0].timeSignature
    }
    
    func setKeySignature(keySignature: Key) {
        for i in 0..<measures.count {
            measures[i].keySignature = keySignature
        }
    }
}
