//
//  SimpleMeasure.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct NotePos {
    var pos: Rational
    let note: Note

    var start: Rational {
        return pos
    }

    var end: Rational {
        return pos + note.duration
    }

    func freespaceBetween(_ later: NotePos) -> FreePos? {
        if later.pos - end > 0 {
            return FreePos(pos: end, duration: later.pos - end)
        }
        return nil
    }

    func startsAtOrAfter(_ position: Rational) -> Bool {
        return position <= start
    }

    func startsStrictlyBefore(_ other: NotePos) -> Bool {
        return start < other.start
    }

    func endsStrictlyBeforeStartOf(_ other: NotePos) -> Bool {
        return end < other.start
    }
}

struct FreePos {
    let pos: Rational
    let duration: Rational

    var start: Rational {
        return pos
    }

    var end: Rational {
        return pos + duration
    }

    func contains(_ position: Rational) -> Bool {
        return start <= position && position <= end
    }

    func freespaceRight(of position: Rational) -> Rational {
        return end > position ? end - position : 0
    }

    func freespaceLeft(of position: Rational) -> Rational {
        return pos > start ? pos - start : 0
    }

    func startsAfter(_ position: Rational) -> Bool {
        return position < start
    }

    func endsBefore(_ position: Rational) -> Bool {
        return end < position
    }
}

struct SimpleMeasure {

    static let defaultTimeSignature: Rational = 4/4

    var timeSignature: Rational
    private(set) var notes: [NotePos] = []

    var capacity: Rational {
        return timeSignature
    }

    var start: Rational {
        return 0
    }

    var end: Rational {
        return timeSignature
    }

    var frees: [FreePos] {

        if notes.isEmpty {
            return [FreePos(pos: start, duration: capacity)]
        }

        var arr: [FreePos] = []
        for (i, np) in notes.enumerated() {


            if i == notes.startIndex { // if first note isn't at position 0, add the free space that runs up to the start of the note

                // first
                if np.pos != 0 {
                    arr.append(FreePos(pos: 0, duration: np.pos))
                }
            } else { // otherwise add the space between the last note and the next note

                // middle: add space to the left of current |np|
                if let fp = notes[i-1].freespaceBetween(np) {
                    arr.append(fp)
                }
            }

            if (i == notes.endIndex - 1) { // add the space after the end of the note if space exists

                // last: add space to the right of current |np|
                if np.end < end {
                    arr.append(FreePos(pos: np.end, duration: end - np.end))
                }
            }
        }
        return arr
    }

    var freespace: Rational {
        return frees.reduce(0) { $0 + $1.duration }
    }

    init(timeSignature: Rational = SimpleMeasure.defaultTimeSignature) {
        self.timeSignature = timeSignature
    }

    func note(at position: Rational) -> Note? {
        guard let i = index(of: position) else { return nil }
        return notes[i].note
    }

    mutating func removeNote(at position: Rational) -> Bool {
        return removeAndReturnNote(at: position) != nil
    }

    mutating func removeAndReturnNote(at position: Rational) -> Note? {
        guard let i = index(of: position) else { return nil }
        return notes.remove(at: i).note
    }

    // speed this up with binary search
    func index(of position: Rational) -> Int? {
        for (i, np) in notes.enumerated() {
            if np.pos == position {
                return i
            }
        }
        return nil
    }

    func freespaceRight(of position: Rational) -> Rational {
        var total: Rational = 0
        for fp in frees {
            if fp.contains(position) {
                total = total + fp.freespaceRight(of: position)
            } else if fp.startsAfter(position) {
                total = total + fp.duration
            }
        }
        return total
    }

    func freespaceLeft(of position: Rational) -> Rational {
        var total: Rational = 0
        for free in frees {
            if free.contains(position) {
                total = total + free.freespaceLeft(of: position)
            } else if free.endsBefore(position) {
                total = total + free.duration
            }
        }
        return total
    }

    // returns nil if the position is after the last index of notes
    // thus, this function returns nil when notes is empty
    func indexToInsert(_ position: Rational) -> Int {
        for (i, np) in notes.enumerated() {
            if np.startsAtOrAfter(position) {
                return i
            }
        }
        return notes.endIndex
    }

    mutating func insert(note: Note, at desiredPosition: Rational) -> Bool {
        var np = NotePos(pos: desiredPosition, note: note)

        if np.start < start { // too early
            return false
        }
        if np.end > end { // too late
            return false
        }
        if note.duration > freespace { // not enough space
            return false
        }

        // At this point, we've determined there's enough space in the measure. now we need to determine whether we...
        // a) insert without moving anything
        // b) insert by nudging right exclusively
        // d) insert by nudging in both directions (might not be able to nudge right at all)

        let indexToInsert = self.indexToInsert(desiredPosition)

        let thisNoteIsTheLastNote = indexToInsert == notes.endIndex
        // note that we depend on short-circuit of first condition to not access notes[i] OOB
        let thereIsEnoughSpaceBeforeStartOfNextNote = !thisNoteIsTheLastNote && notes[indexToInsert].startsAtOrAfter(np.end)

        // A)
        if thisNoteIsTheLastNote || thereIsEnoughSpaceBeforeStartOfNextNote {
            notes.insert(np, at: indexToInsert)
            return true
        }
        // there wasn't enough space before the start of the next element

        let freespaceR = freespaceRight(of: desiredPosition)

        // B)
        if np.note.duration <= freespaceR {
            // note can't fit automatically, but it can if we nudge to the right
            var endOfPreviousNote = np.end
            for i in stride(from: indexToInsert, to: notes.endIndex, by: 1) {
                notes[i].pos = max(notes[i].pos, endOfPreviousNote)
                endOfPreviousNote = notes[i].end
            }
            notes.insert(np, at: indexToInsert)
            return true
        }

        // C)

        // take all of the free space on the right and update |np|'s position
        // optimization: only do this if freespaceR > 0
        var endOfPreviousNote = desiredPosition + freespaceR
        for i in stride(from: indexToInsert, to: notes.endIndex, by: 1) {
            notes[i].pos = max(notes[i].pos, endOfPreviousNote)
            endOfPreviousNote = notes[i].end
        }
        np.pos = np.pos - np.note.duration + freespaceR

        // take freespace to the left (only if necessary)
        var startOfNextNote = np.pos
        for i in stride(from: indexToInsert - 1, through: 0, by: -1) {
            let thereIsOverlap = startOfNextNote < notes[i].end
            if thereIsOverlap {
                let sizeOfOverlap = notes[i].end - startOfNextNote
                notes[i].pos = notes[i].pos - sizeOfOverlap
            }
            startOfNextNote = notes[i].pos
        }

        notes.insert(np, at: indexToInsert)
        return true
    }
}
