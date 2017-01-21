//
//  Measure.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct Measure {
    
    // the key signature eg. G Major or d minor
    let key: Key
    
    let time: Rational
    
    // holds duration because note is immutable
    struct NotePosition {
        var pos: Rational
        var duration: Rational
        var note: Note
        var isFree: Bool
    }
    
    private var notes: [NotePosition]
    
    // inserts a Note at the given position in the measure
    // returns whether the operation succeeded
    mutating func insertNoteAt(note: Note, position: Rational) -> Bool {
        
        let noteEnd = position + note.duration
        
        for (i, notePosition) in notes.enumerated() {
            
            let currPos = notePosition.pos
            let currNote = notePosition.note
            
            let currEnd = currPos + notePosition.duration
            
            if notePosition.isFree {
            
                // check start of new note
                let startOK = (position >= currPos) && (position <= currEnd)
                // check end of new note
                let endOK = (noteEnd >= currPos) && (noteEnd <= currEnd)
                
                if (startOK && endOK) {
                    
                    let diff = currNote.duration - note.duration
                    
                    // add Note and change free space
                    
                    if currPos == position {
                        // need to put the free space after the new note if the start is the same
                        notes.insert(NotePosition(pos: position, duration: note.duration, note: note, isFree: false), at: i)
                        
                        if diff == 0 {
                            // remove this free space
                            notes.remove(at: i+1)

                        } else {
                            // resize and reposition free space
                            notes[i+1].duration = diff
                            notes[i+1].pos = notes[i].pos + note.duration
                        }

                        return true
                        
                    } else if currEnd == noteEnd {
                        // need to put the free space before the new note if the end is the same
                        
                        notes.insert(NotePosition(pos: position, duration: note.duration, note: note, isFree: false), at: i+1)
                        
                        if diff == 0 {
                            // remove this free space
                            notes.remove(at: i)
                            
                        } else {
                            // resize free space
                            notes[i].duration = diff
                        }
                        
                        return true
                        
                    } else {
                        // need to put the note in the middle of the free space and cut it up
                        
                        notes.insert(NotePosition(pos: position, duration: note.duration, note: note, isFree: false), at: i+1)
                        
                        // resize free space before the note
                        notes[i].duration = position - currPos
                        
                        // add leftovers in new free space after new note
                        let np = NotePosition(pos: noteEnd, duration: currEnd - noteEnd, note: Note(value: .whole, letter: .B, octave: 5), isFree: true)
                        self.notes.insert(np, at: i+2)
                        
                        return true
                    }
                    
                }
            }
        }
        return false
    }
    
    // TODO coalesce
    
    // TODO getAt(Rational)
    // TODO getAll
    // TODO removeAt(Rational
    
    init(time: Rational = 4/4, key: Key = Key()) {
        self.time = time
        self.key = key
        
        // notes starts with a single free note that takes up the whole measure
        let np = NotePosition(pos: 0, duration: time, note: Note(value: .whole, letter: .B, octave: 5), isFree: true)
        self.notes = [np]
    }
    
    // TODO duration checking (see #37)
}
