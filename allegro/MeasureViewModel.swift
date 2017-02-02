//
//  MeasureViewModel.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/24/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct MeasureViewModel {

    typealias Beam = [NoteViewModel]
    
    private(set) var noteViewModels = [NoteViewModel]()

    var timeSignature: Rational {
        return measure.timeSignature
    }

    // |beams| returns a list of beams. Each beam is a list of notes which must be beamed together.
    // TODO(btc): Is it more convenient to be provided with a list of positions (Rational) instead?
    var beams: [Beam] = [] // TODO: implement

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

    private let measure: Measure

    init(_ measure: Measure) {
        self.measure = measure
        for (position, note) in measure.getAllNotes() {
            var newNoteViewModel = NoteViewModel(note: note, position: position)
            newNoteViewModel.displayAccidental = checkAccidentalDisplay(currentNote: newNoteViewModel)
            noteViewModels.append(newNoteViewModel)
        }
    }
}
