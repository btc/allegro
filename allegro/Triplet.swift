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
        guard(notesArr.count <= 3 && notesArr.count >= 1) else { return nil }
        self.duration = notesArr[0].duration * 2
        for notePos in notesArr {
            guard(notePos.duration == notesArr[0].duration) else { return nil }
            notePos.note.triplet = self
            notes.append(notePos.note)
        }
    }
    
    func addNote(notePos: NotePos) -> Bool {
        guard(notePos.duration == self.notes[0].duration) else { return false }
        guard(self.notes.count < 3) else { return false }
        notePos.note.triplet = self
        notes.append(notePos.note)
        return true
    }
    
    func removeNote(notePos: NotePos) -> Bool {
        for (i, note) in self.notes.enumerated() {
            if(notePos.note == note) {
                self.notes.remove(at: i)
                return true
            }
        }
        return false
    }
    
    func isEmpty() -> Bool {
        // find any non-rests
        let results = notes.filter {$0.rest == false}
        return results.isEmpty
    }
    
    static func ==(lhs: Triplet, rhs: Triplet) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
