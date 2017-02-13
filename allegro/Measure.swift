//
//  Measure.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

// holds information about this specific note in the measure
// the position is measured in relation to the time signature as a simplified rational
// eg. in 3/4 time, a quarter note on beat 2 has position 1/2, and there is no space for another note after it.
struct NotePosition {
    var pos: Rational
    var isFree: Bool {
        get {
            return (note == nil)
        }
    }
    var note: Note?
    var durationOfFree: Rational?
}

struct Measure {

    static let defaultTimeSignature: Rational = 4/4

    // the key signature eg. G Major or d minor
    var key: Key
    
    // used in simplified form, eg. 2/2 and 4/4 are treated the same
    var timeSignature: Rational

    private(set) var positions: [NotePosition]
    
    private(set) var ties: [Tie] = [Tie]()

    // returns all notes and their positions in O(n)
    var notes: [(pos: Rational, note: Note)] {
        var ret = [(Rational,Note)]()
        for notePosition in positions {
            if !notePosition.isFree, let note = notePosition.note {
                ret.append((notePosition.pos, note))
            }
        }
        return ret
    }

    // returns all of the free space in the measure in O(n)
    var frees: [(pos: Rational, duration: Rational)] {
        var ret = [(Rational,Rational)]()
        for notePosition in positions {
            if notePosition.isFree, let duration = notePosition.durationOfFree {
                ret.append((notePosition.pos, duration))
            }
        }
        return ret
    }

    init(time: Rational = Measure.defaultTimeSignature, key: Key = Key()) {
        self.timeSignature = time
        self.key = key

        // notes starts with a single free NotePosition that takes up the whole measure
        let np = NotePosition(pos: 0, note: nil, durationOfFree: time)
        self.positions = [np]
    }

    // adds a Tie to this measure
    // returns true on success
    mutating func addTie(startPos: Rational, endPos: Rational) -> Bool {
        guard let startNote = note(at: startPos) else {return false}
        guard let endNote = note(at: endPos) else { return false}
        ties.append(Tie(startNote: startNote, endNote: endNote))
        return true
    }

    // inserts a Note at the given position in the measure in O(n)
    // returns whether the operation succeeded
    // tries to use next freespace if that will allow the note to be placed
    mutating func insert(note: Note, at position: Rational) -> Bool {
        
        let noteEnd = position + note.duration
        
        for (i, notePosition) in positions.enumerated() {

            guard notePosition.isFree, let durationOfFree = notePosition.durationOfFree else { continue }

            let currPos = notePosition.pos
            let currEnd = currPos + durationOfFree
            let diff = durationOfFree - note.duration

            // check that start of new note falls within this freespace
            guard (position >= currPos) && (position <= currEnd) else { continue }

            // check end of new note
            guard (noteEnd >= currPos) && (noteEnd <= currEnd) else { continue }

            // add Note and change free space
            if currPos == position {
                // need to put the free space after the new note if the start is the same
                positions.insert(NotePosition(pos: position, note: note, durationOfFree: nil), at: i)

                if diff == 0 {
                    // remove this free space
                    positions[i+1].note = nil
                    positions.remove(at: i+1)

                } else {
                    // resize and reposition free space
                    positions[i+1].durationOfFree = diff
                    positions[i+1].pos = positions[i].pos + note.duration
                }

                return true

            } else if currEnd == noteEnd {
                // need to put the free space before the new note if the end is the same

                positions.insert(NotePosition(pos: position, note: note, durationOfFree: nil), at: i+1)

                if diff == 0 {
                    // remove this free space
                    positions[i].note = nil
                    positions.remove(at: i)

                } else {
                    // resize free space
                    positions[i].durationOfFree = diff
                }

                return true

            } else {
                // need to put the note in the middle of the free space and cut it up

                positions.insert(NotePosition(pos: position, note: note, durationOfFree: nil), at: i+1)

                // resize free space before the note
                positions[i].durationOfFree = position - currPos

                // add leftovers in new free space after new note
                let np = NotePosition(pos: noteEnd, note: nil, durationOfFree: currEnd - noteEnd)
                self.positions.insert(np, at: i+2)

                return true
            }

        }
        return false
    }

    // determines if this note can nudge its neighbor to the right in O(n)
    func canNudge(note: Note, at position: Rational) -> Rational? {
        for (i, notePosition) in positions.enumerated() {
            // look for the freespace NotePosition that contains this requested position

            guard notePosition.isFree, let durationOfFree = notePosition.durationOfFree else { continue }
            let currPos = notePosition.pos
            let currEnd = currPos + durationOfFree

            // check that start of new note falls within this freespace
            guard (position >= currPos) && (position <= currEnd) else { continue }

            // i+1 must be a note bc otherwise it would be coalesced
            guard positions.indices.contains(i+1) else { continue }
            let nextNotePosition = positions[i+1]
            guard let nextNote = nextNotePosition.note else { continue }

            // have to check that i+2 is freespace
            guard positions.indices.contains(i+2) else { continue }
            let nextFreeNotePosition = positions[i+2]
            guard nextFreeNotePosition.isFree, let nextDurationOfFree = nextFreeNotePosition.durationOfFree else { continue }

            // check that there is enough space for both notes after using nextFree
            if position + note.duration + nextNote.duration <= nextFreeNotePosition.pos + nextDurationOfFree {
                return nextNotePosition.pos
            }
        }
        return nil
    }

    // inserts a note in O(n) at the given position
    // attempts to nudge 1 note on the right to make room if possible
    mutating func insertWithNudge(note: Note, at position: Rational) -> Bool {

        // try normal insert
        if insert(note: note, at: position) {
            return true
        }

        // try using this note to nudge its neighbor on the right
        guard let neighborPosition = canNudge(note: note, at: position) else { return false }

        // remove and save neighbor
        guard let neighbor = removeAndReturnNote(at: neighborPosition) else { return false }

        // try to insert the new note
        if !insert(note: note, at: position) {
            // failed, so we replace neighbor where it came from
            if insert(note: neighbor, at: neighborPosition) && DEBUG {
                Log.error?.message("Couldn't re-insert removed note. Developer Error.")
            }
            return false
        }
        // re-insert neighbor
        return insert(note: neighbor, at: position + note.duration)
    }

    // Changes the dot on a note in O(n)
    // returns success of the operation
    // Removes original note, adds a dot, and inserts with nudge
    mutating func dotNote(at position: Rational, dot: Note.Dot) -> Bool {
        // remove original note and add a dot
        guard let note = removeAndReturnNote(at: position) else { return false }
        let originalDot = note.dot
        note.dot = dot

        // re-insert with new dot
        if insertWithNudge(note: note, at: position) {
            return true
        }

        // re-insert original note if we were unable to insert dotted note with nudge
        note.dot = originalDot
        if !insert(note: note, at: position) && DEBUG {
            Log.error?.message("Unable to re-insert note after failed dotting. Developer Error.")
        }
        return false
    }


    // gets a Note at a specific position in the measure in O(n)
    func note(at position: Rational) -> Note? {
        for notePosition in positions {
            if notePosition.pos == position && !notePosition.isFree {
                return notePosition.note
            }
        }
        return nil
    }
    
    // removes whichever note is at the specified position in O(n)
    // returns whether the operation was successful
    mutating func removeNote(at position: Rational) -> Bool {
        return removeAndReturnNote(at: position) != nil
    }

    // removes whichever note is at the specified position in O(n)
    // returns the note if it was found
    mutating func removeAndReturnNote(at position: Rational) -> Note? {
        var removed: Note?
        for i in 0..<positions.count {
            if positions[i].pos == position && !positions[i].isFree {
                if let note = positions[i].note {
                    removed = note
                    positions[i].note = nil
                    positions[i].durationOfFree = note.duration
                }
            }
        }
        // coalesce after loop bc it may delete entries that we are iterating over
        coalesce()
        return removed
    }
    
    // coalesces free space NotePosition objects in O(n)
    private mutating func coalesce() {
        var i = 0
        while(true) {
            if (i == positions.count - 1) {
                break
            }
            let curr = positions[i]
            if curr.isFree, let durationOfFree = curr.durationOfFree {
                let next = positions[i+1]
                if next.isFree, let nextDurationOfFree = next.durationOfFree {
                    // coalesce i+1 into i
                    positions[i].durationOfFree = durationOfFree + nextDurationOfFree
                    positions.remove(at: i+1)
                    continue
                }
            }
            i += 1
        }
    }
    
    // Finds the nearest previous note with the same letter if it exists
    func getPrevLetterMatch(noteLetter: Note.Letter, position: Rational) -> Note? {
        var match: Note? = nil
        var foundOrig = false
        for notePosition in positions.reversed() {
            if let curr = notePosition.note {
            
                // find original note
                if notePosition.pos == position {
                    foundOrig = true
                    continue
                }
            
                // find previous note with same letter
                if foundOrig && curr.letter == noteLetter {
                    match = notePosition.note
                    break
                }
            }
        }
        
        return match
    }
}
