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
    var isFree: Bool
    var note: Note?
    var durationOfFree: Rational?
}

struct Measure {

    static let defaultTimeSignature: Rational = 4/4

    // the key signature eg. G Major or d minor
    let key: Key
    
    let timeSignature: Rational

    private var notes: [NotePosition]

    init(time: Rational = Measure.defaultTimeSignature, key: Key = Key()) {
        self.timeSignature = time
        self.key = key

        // notes starts with a single free note that takes up the whole measure
        let np = NotePosition(pos: 0, isFree: true, note: nil, durationOfFree: time)
        self.notes = [np]
    }

    // inserts a Note at the given position in the measure
    // returns whether the operation succeeded
    mutating func insert(note: Note, at position: Rational) -> Bool {
        
        let noteEnd = position + note.duration
        
        for (i, notePosition) in notes.enumerated() {

            guard notePosition.isFree, let durationOfFree = notePosition.durationOfFree else { continue }

            let currPos = notePosition.pos
            let currEnd = currPos + durationOfFree

            // check start of new note
            let startOK = (position >= currPos) && (position <= currEnd)
            // check end of new note
            let endOK = (noteEnd >= currPos) && (noteEnd <= currEnd)

            if (startOK && endOK) {

                let diff = durationOfFree - note.duration

                // add Note and change free space

                if currPos == position {
                    // need to put the free space after the new note if the start is the same
                    notes.insert(NotePosition(pos: position, isFree: false, note: note, durationOfFree: nil), at: i)

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

                    notes.insert(NotePosition(pos: position, isFree: false, note: note, durationOfFree: nil), at: i+1)

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

                    notes.insert(NotePosition(pos: position, isFree: false, note: note, durationOfFree: nil), at: i+1)

                    // resize free space before the note
                    notes[i].durationOfFree = position - currPos

                    // add leftovers in new free space after new note
                    let np = NotePosition(pos: noteEnd, isFree: true, note: nil, durationOfFree: currEnd - noteEnd)
                    self.notes.insert(np, at: i+2)

                    return true
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
            if !notePosition.isFree, let note = notePosition.note {
                ret.append((notePosition.pos, note))
            }
        }
        return ret
    }
    
    // TODO removeAt(Rational)
    
    // coalesces free space
    private mutating func coalesce() {
        for i in 0..<notes.count - 1 {
            let curr = notes[i]
            if curr.isFree, let durationOfFree = curr.durationOfFree {
                let next = notes[i+1]
                
                if next.isFree, let nextDurationOfFree = next.durationOfFree {
                    // coalesce i+1 into i
                    notes[i].durationOfFree = durationOfFree + nextDurationOfFree
                    notes.remove(at: i+1)
                }
            }
        }
    }
    
    // TODO duration checking (see #37)
}
