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
    
    // determines beams and creates NoteViewModels
    private mutating func noteLayout() {
        
        var currBeam: Beam? = nil
        var currValue: Note.Value? = nil
        var currFlipped: Bool? = nil
        
        for (position, note) in measure.getAllNotes() {
            var newNoteViewModel = NoteViewModel(note: note, position: position)
            
            // TODO (kevin) fix bug: displays all accidentals right now
            newNoteViewModel.displayAccidental = checkAccidentalDisplay(note: note, position: position)

            // TODO more comprehensive rule that takes beams into account
            if newNoteViewModel.pitch > 0 {
                newNoteViewModel.flipped = true
            }
            self.noteViewModels.append(newNoteViewModel)
            
            // beams v1: consecutive, same-direction, same-type
            
            if newNoteViewModel.hasFlag {
                if currBeam == nil {
                    currBeam = Beam()
                    currValue = note.value
                    currFlipped = newNoteViewModel.flipped
                }
                
                // same-direction and same-type
                if newNoteViewModel.flipped == currFlipped && currValue == note.value {
                    currBeam?.append(newNoteViewModel)
                }
                
                else {
                    
                    if let beam = currBeam {
                        // this run is over
                        beams.append(beam)
                        currBeam = nil
                        currValue = nil
                        currFlipped = nil
                    }
                }

            } else {
                if let beam = currBeam {
                    // this run is over
                    beams.append(beam)
                    currBeam = nil
                    currValue = nil
                    currFlipped = nil
                }
            }
            // do nothing if there is no curr beam and note shouldn't be beamed
        }
        
        // append currBeam at the end of the measure
        if let beam = currBeam {
            beams.append(beam)
        }
        
        // remove beams with only 1 element
        var i = 0
        while i < beams.count {
            if beams[i].count <= 1 {
                beams.remove(at: i)
                i += 1
            }
            i += 1
        }

    }

    init(_ measure: Measure) {
        self.measure = measure
        noteLayout()
    }
    
    
}
