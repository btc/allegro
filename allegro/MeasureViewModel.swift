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
    typealias Beam = [NoteViewModel]
    
    private(set) var beams: [Beam] = []

    var timeSignature: Rational {
        return measure.timeSignature
    }
    
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
            // no prev note -> default
            if(previous == nil) {
                return true
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
        // key sig hit
        else {
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
    
    private mutating func setFlipped(beamIndex: Int, flipped: Bool) {
        for i in 0..<beams[beamIndex].count {
            beams[beamIndex][i].flipped = flipped
        }
    }
    
    // determines beams and creates NoteViewModels
    private mutating func noteLayout() {
        
        // recursive formulation
        
        var startBeam = Beam()
        for (pos, note) in measure.getAllNotes() {
            let nvm = NoteViewModel(note: note, position: pos)
            startBeam.append(nvm)
            noteViewModels.append(nvm)
        }
        processBeam(beam: startBeam)
        
        // cleanup beams
        
        // align flipped for all notes in each beam
        for (beamIndex, beam) in beams.enumerated() {
            var flippedCount = 0
            for note in beam {
                if note.flipped {
                    flippedCount += 1
                }
            }
            // more than half are flipped
            if flippedCount * 2 > beam.count {
                setFlipped(beamIndex: beamIndex, flipped: true)
            } else {
                setFlipped(beamIndex: beamIndex, flipped: false)
            }
        }
    }
    
    private mutating func processBeam(beam: Beam) {
        let (splitIndex, discard) = splitBeam(beam: beam)
        
        // no split
        if splitIndex == 0 {
            beams.append(beam)
            return
        }
        
        if !discard {
            let lhs = Beam(beam[0..<splitIndex])
            processBeam(beam: lhs)
        }
        
        let rhs = Beam(beam[splitIndex..<beam.count])
        processBeam(beam: rhs)
    }
    
    // returns index of first element of second part of split
    // eg. beam should be split as beam[0..<i] and beam[i...end]
    // also return whether the first portion should be discarded
    private func splitBeam(beam: Beam) -> (splitIndex: Int, discard: Bool) {
        // do not split if there is nothing to split
        if beam.count <= 1 {
            // discard so that we don't have 1 element beams
            return (0, true)
        }
        
        // split after the first run
        // v1 run = same value
        let value = beam[0].value
        for (index, note) in beam.enumerated() {
            if note.value != value {
                // split here because this is the first note that doesn't match
                if value.hasFlag {
                    return (index, false)
                } else {
                    // discard if this run has no flag
                    return (index, true)
                }
            }
        }
        // no split if everything is in the run
        if value.hasFlag {
            return (0, false)
        } else {
            // but this run has no flag so we discard it
            return (0, true)
        }
        
    }

    init(_ measure: Measure) {
        self.measure = measure
        noteLayout()
    }
    
    
}
