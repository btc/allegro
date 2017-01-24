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
}
