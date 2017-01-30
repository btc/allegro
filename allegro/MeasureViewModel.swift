//
//  MeasureViewModel.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/24/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct MeasureViewModel {
    
    private(set) var noteViewModels = [NoteViewModel]()

    var timeSignature: Rational {
        return measure.timeSignature
    }

    var notes: [NoteViewModel] {
        return measure.getAllNotes().map { NoteViewModel(note: $0.note, position: $0.pos) }
    }
    
    /*
        For the current NoteViewModel, determines if accidental should be displayed or not
        return true: accidental should be displayed (default)
        return false: accidental should not be displayed
        Add big O runtime to comments
     */
    private func checkAccidentalDisplay(currentNote: NoteViewModel) -> Bool {
        // get previous matching note from the measure. getPrevLetterMatch(currentNote) can return nil
        let previous = self.measure.getPrevLetterMatch(noteLetter: currentNote.letter, position: currentNote.position)
        
        // get key signature hit from the measure (returns accidental if the current note is in the key signature or nil if not)
        let keyHit = self.measure.key.keyHit(currentNoteLetter: currentNote.letter)
        
        // no key sig hit
        if(keyHit == nil) {
            // no prev note -> default
            if(previous == nil) {
                return true
            }
            // prev note
            else {
                // same accidental as prev -> no display
                if(currentNote.accidental.hashValue == previous?.accidental.hashValue) {
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
                if(currentNote.accidental.hashValue == keyHit?.hashValue) {
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
                if(currentNote.accidental.hashValue == previous?.accidental.hashValue) {
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
            let newNoteViewModel = NoteViewModel(note: note, position: position)
            noteViewModels.append(newNoteViewModel)
        }
    }
}
