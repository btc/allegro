//
//  MeasureViewModel.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/24/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct MeasureViewModel {

    var timeSignature: Rational {
        return measure.timeSignature
    }

    var notes: [NoteViewModel] {
        return measure.getAllNotes().map { NoteViewModel(note: $0.note, position: $0.pos) }
    }

    private let measure: Measure

    init(_ measure: Measure) {
        self.measure = measure
    }
}
