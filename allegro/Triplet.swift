//
//  Triplet.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//
import Rational

class Triplet {
    let notes: [Note]   // keep track of notes in the triplet
    let realDuration: Rational  //duration of each note in the triplet
    init?(note1: Note, note2: Note, note3: Note, nominalDuration: Rational) {
        guard(note1.duration == note2.duration && note2.duration == note3.duration) else {
            return nil
        }
        self.notes = [Note](arrayLiteral: note1, note2, note3)
        self.realDuration = nominalDuration * 2/3;
    }
}
