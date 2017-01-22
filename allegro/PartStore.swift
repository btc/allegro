//
//  PartStore.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/21/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

class PartStore {

    let part: Part

    var selectedNoteDuration: Note.Duration = .whole

    init(part: Part) {
        self.part = part
    }

    func insert(note: Note, intoMeasureIndex i: Int, at position: Rational) -> Bool {
        while part.measureCount <= i {
            part.extend() // allows caller to insert into a measure that doesn't exist until _now_.
        }
        Log.info?.message("insert \(note.duration.description) into measure \(i) at \(position)")
        return part.insert(note: note, intoMeasureIndex: i, at: position)
    }

    func getNotes(measureIndex i: Int) -> [(pos: Rational, note: Note)] {
        guard part.measures.indices.contains(i) else { return [] } // allows caller to create measures lazily
        return part.measures[i].getAllNotes()
    }

    func measure(at index: Int) -> Measure {
        if part.measures.indices.contains(index) {
            return part.measures[index]
        }

        // else return a new measure with same time signature as previous
        if let last = part.measures.last {
            return Measure(time: last.timeSignature)
        }

        // else return a new measure
        return Measure()
    }
}
