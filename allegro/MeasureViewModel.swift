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
        Add big O runtime to comments
     */
    private func setAccidentalDisplay(currentNote: NoteViewModel) -> Bool {
        // get previous matching note from the measure
        // call self.measure.getPrevLetterMatch(currentNote). Can return nil
        
        // get key signature hit from the measure 
        // call self.measure.key.keyHit(currentNoteLetter)
        
        // key sig hit
        /* TODO */
            // prev note
                // same accidental as prev -> no display
                // different accidental from prev -> default
        
            // no prev note
                // same accidental as key sig hit ->
                // different accidental from key sig hit
        
        // no key sig hit
        /* TODO */
            // prev note
                // same accidental as prev
                // different accidental from prev
        
            // no prev note
                //
        return false
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
