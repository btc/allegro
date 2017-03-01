//
//  Triplet.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//
import Rational

class Triplet {
    var notes: [Note] = [Note]()  // keep track of notes in the triplet
    let modifier: Rational = 2/3
    let duration: Rational
    init?(notesArr: [NotePos]) {
        guard(notesArr.count == 3) else { return nil }
        guard(notesArr[0].duration == notesArr[1].duration && notesArr[1].duration == notesArr[2].duration) else { return nil }
        self.duration = notesArr[0].duration * 2
        for notePos in notesArr {
            notePos.note.triplet = self
            notes.append(notePos.note)
        }
    }
    
    func isEmpty() -> Bool {
        // find any non-rests
        let results = notes.filter {$0.rest == false}
        return results.isEmpty
    }
}
