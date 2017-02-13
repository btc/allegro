//
//  MeasureViewModel.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/24/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct MeasureViewModel {

    private let measure: Measure
    private(set) var noteViewModels = [NoteViewModel]()

    // Beams are the lines that connect groups of eighth notes, sixteenth notes, etc
    // We just store a collection of notes that should be beamed together by MeasureView
    typealias Beam = Array<NoteViewModel>

    private(set) var beams: [Beam] = []

    var timeSignature: Rational {
        return measure.timeSignature
    }
    
    private let rules: [(Beam, Int) -> (left: Beam, right: Beam)?] = [
        { (b, i) in // discard if the beam has only 1 element
            b.count <= 1 ? ([], []) : nil
        },
        { (b: Beam, i) in // split when the beam has more than 2 elements
            i >= 2 ? b.partition(index: i) : nil
        },
        { (b, i) in // discard when the note has no flag
            if b[i].hasFlag {
                return nil
            }
            if b.indices.contains(i+1) {
                return ([], b.partition(index: i+1).right)
            }
            return ([], [])
        },
        { (b, i) in // split when value changes
            if i == 0 {
                return nil
            }
            if b[i].value != b[i-1].value {
                return b.partition(index: i)
            }
            return nil
        }
    ]
    /*
        For the current NoteViewModel, determines if accidental should be displayed or not
        return true: accidental should be displayed (default)
        return false: accidental should not be displayed
        Add big O runtime to comments
     */
    private func checkAccidentalDisplay(note currentNote: Note, position: Rational) -> Bool {
        // get previous matching note from the measure. getPrevLetterMatch(currentNote) can return nil
        let previous = measure.getPrevLetterMatch(noteLetter: currentNote.letter, position: position)
        
        // get key signature hit from the measure (returns accidental if the current note is in the key signature or nil if not)
        let keyHit = measure.key.keyHit(currentNoteLetter: currentNote.letter)
        
        // no key sig hit
        if(keyHit == nil) {
            //print("no key sig hit")
            // no prev note -> default
            if(previous == nil) {
                if(currentNote.accidental == Note.Accidental.natural) {
                    //print("no previous note, no key hit, natural. returning false (no display)")
                    return false
                }
                //print("no previous note, returning true (display)")
                return true
            }
            // prev note
            else {
                // same accidental as prev -> no display
                if(currentNote.accidental == previous?.accidental) {
                    //print("previous note found, same accidental. returning false (no display)")
                    return false
                }
                // different accidental from prev -> default
                else {
                    //print("prev found, diff accidental. returning true (display)")
                    return true
                }
            }
        }
        // key sig hit
        else {
            //print("key sig hit")
            // no prev
            if(previous == nil) {
                // same accidental as key sig hit -> no display
                if(currentNote.accidental == keyHit) {
                    return false
                }
                // different accidental from key sig hit -> default
                else {
                    return true
                }
            }
            // prev note
            else {
                // same accidental as prev -> no display
                if(currentNote.accidental == previous?.accidental) {
                    return false
                }
                // different accidental from prev -> default
                else {
                    return true
                }
            }
        }
    }
    
    // determines beams and creates NoteViewModels
    private func computeBeams() -> [Beam] {
        
        // recursive formulation
        
        var startBeam = Beam()
        for nvm in noteViewModels {
            startBeam.append(nvm)
        }
        let beams = computeBeamsRecursive(beam: startBeam)
        
        // cleanup beams
        
        // align flipped for all notes in each beam
        for beam in beams {

            var flippedCount = 0
            for note in beam {
                if note.flipped {
                    flippedCount += 1
                }
            }

            let flipped = flippedCount * 2 > beam.count // more than half are flipped
            for i in 0..<beam.count {
                beam[i].flipped = flipped
            }
        }
        return beams
    }
    
    private func computeBeamsRecursive(beam: Beam) -> [Beam] {
        if beam.isEmpty {
            return []
        }
        let (left, right) = splitBeam(beam: beam)

        let beamWasNotSplit = left.count == beam.count || right.count == beam.count

        if beamWasNotSplit {
            return [beam]
        }
        var beams = [Beam]()
        beams.append(contentsOf: computeBeamsRecursive(beam: left))
        beams.append(contentsOf: computeBeamsRecursive(beam: right))
        return beams
    }
    
    // returns index of first element of second part of split
    // eg. beam should be split as beam[0..<i] and beam[i...end]
    // also return whether the first portion should be discarded
    private func splitBeam(beam: Beam) -> (left: Beam, right: Beam) {
        for i in 0..<beam.count {
            for rule in rules {
                if let split = rule(beam, i) {
                    return split
                }
            }
        }
        return ([], beam)
    }

    init(_ measure: Measure) {
        self.measure = measure
        for (position, note) in measure.notes {
            let newNoteViewModel = NoteViewModel(note: note, position: position)
            newNoteViewModel.displayAccidental = checkAccidentalDisplay(note: note, position: position)
            noteViewModels.append(newNoteViewModel)
        }

        beams = computeBeams()
    }

}
