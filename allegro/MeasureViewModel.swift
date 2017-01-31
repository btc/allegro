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
    private func checkAccidentalDisplay(currentNote: NoteViewModel) -> Bool {
        // get previous matching note from the measure. getPrevLetterMatch(currentNote) can return nil
        let previous = measure.getPrevLetterMatch(noteLetter: currentNote.letter, position: currentNote.position)
        
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

    init(_ measure: Measure) {
        self.measure = measure
        for (position, note) in measure.getAllNotes() {
            var newNoteViewModel = NoteViewModel(note: note, position: position)
            newNoteViewModel.displayAccidental = checkAccidentalDisplay(currentNote: newNoteViewModel)
            noteViewModels.append(newNoteViewModel)
            
            // beams v1: consecutive, same-direction, same-type
            var currBeam: Beam? = nil
            var currValue: Note.Value? = nil
            var currDirection: Bool? = nil // true for above centerline, false for below
            if newNoteViewModel.hasFlag {
                if currBeam == nil {
                    currBeam = Beam()
                    currValue = note.value
                    
                    // TODO this is different than NoteView flipped, so they must be reconciled
                    currDirection = (newNoteViewModel.pitch >= 0)
                }
                // same-direction and same-type
                if (newNoteViewModel.pitch >= 0) == currDirection && currValue == note.value {
                    currBeam?.append(newNoteViewModel)
                }
                
            } else if let beam = currBeam {
                // this run is over
                beams.append(beam)
                currBeam = nil
                currValue = nil
            }
            // do nothing if there is no curr beam and note shouldn't be beamed
        }
    }
    
    
}
