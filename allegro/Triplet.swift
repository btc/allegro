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
    let nominalDuration: Rational
    init?(notesArr: [Note]) {
        guard(notesArr[0].duration == notesArr[1].duration && notesArr[1].duration == notesArr[2].duration)
        else {
            return nil
        }
        self.notes = notesArr
        self.nominalDuration = notes[0].duration
        self.realDuration = nominalDuration * 2/3;
    }
    
    func isEmpty() -> Bool {
        // find any non-rests
        let results = notes.filter {$0.rest == false}
        return results.isEmpty
    }
}
