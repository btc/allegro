//
//  Measure.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

// TODO(btc): make note and durationOfFree optional types

private struct NotePosition {
    var pos: Rational
    var note: Note
    var isFree: Bool
    var durationOfFree: Rational
}

struct Measure {

    // the key signature eg. G Major or d minor
    let key: Key
    
    let timeSignature: Rational

    private var notes: [NotePosition]

    init(time: Rational = 4/4, key: Key = Key()) {
        self.timeSignature = time
        self.key = key

        // notes starts with a single free note that takes up the whole measure
        let np = NotePosition(pos: 0, note: Note(value: .whole, letter: .B, octave: 5), isFree: true, durationOfFree: time)
        self.notes = [np]
    }

    // inserts a Note at the given position in the measure
    // returns whether the operation succeeded
    mutating func insert(note: Note, at position: Rational) -> Bool {
        
        let noteEnd = position + note.duration
        
        for (i, notePosition) in notes.enumerated() {
            
            let currPos = notePosition.pos
            let currNote = notePosition.note
            
            let currEnd = currPos + notePosition.durationOfFree
            
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
                        notes.insert(NotePosition(pos: position, note: note, isFree: false, durationOfFree: note.duration), at: i)
                        
                        if diff == 0 {
                            // remove this free space
                            notes.remove(at: i+1)

                        } else {
                            // resize and reposition free space
                            notes[i+1].durationOfFree = diff
                            notes[i+1].pos = notes[i].pos + note.duration
                        }

                        return true
                        
                    } else if currEnd == noteEnd {
                        // need to put the free space before the new note if the end is the same
                        
                        notes.insert(NotePosition(pos: position, note: note, isFree: false, durationOfFree: note.duration), at: i+1)
                        
                        if diff == 0 {
                            // remove this free space
                            notes.remove(at: i)
                            
                        } else {
                            // resize free space
                            notes[i].durationOfFree = diff
                        }
                        
                        return true
                        
                    } else {
                        // need to put the note in the middle of the free space and cut it up
                        
                        notes.insert(NotePosition(pos: position, note: note, isFree: false, durationOfFree: note.duration), at: i+1)
                        
                        // resize free space before the note
                        notes[i].durationOfFree = position - currPos
                        
                        // add leftovers in new free space after new note
                        let np = NotePosition(pos: noteEnd, note: Note(value: .whole, letter: .B, octave: 5), isFree: true, durationOfFree: currEnd - noteEnd)
                        self.notes.insert(np, at: i+2)
                        
                        return true
                    }
                    
                }
            }
        }
        return false
    }
    
    // gets a Note at a specific position in the measure
    func getNote(at position: Rational) -> Note? {
        for notePosition in notes {
            if notePosition.pos == position && !notePosition.isFree {
                return notePosition.note
            }
        }
        return nil
    }
    
    // returns all notes and their positions
    func getAllNotes() -> [(pos: Rational, note: Note)] {
        var ret = [(Rational,Note)]()
        for notePosition in notes {
            if !notePosition.isFree {
                ret.append((notePosition.pos, notePosition.note))
            }
        }
        return ret
    }
    
    // TODO removeAt(Rational)
    
    // coalesces free space
    private mutating func coalesce() {
        for i in 0..<notes.count - 1 {
            if notes[i].isFree {
                let nextNotePosition = notes[i+1]
                
                if nextNotePosition.isFree {
                    // coalesce i+1 into i
                    notes[i].durationOfFree = notes[i].durationOfFree + nextNotePosition.durationOfFree
                    notes.remove(at: i+1)
                }
            }
        }
    }
    
    // TODO duration checking (see #37)
}
