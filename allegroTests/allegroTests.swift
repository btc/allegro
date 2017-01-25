//
//  allegroTests.swift
//  allegroTests
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import XCTest
@testable import allegro
import Rational // TODO figure out how to import Rational here without linker error

class allegroTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPart() {
        let part = Part()
        XCTAssert(part.tempo == 120, "New Part tempo default is 120 bpm")
    }

    func testMeasureBasic() {
        let n = Note(duration: .whole, letter: .A, octave: 1)
        var m = Measure(time: 3/4)
        XCTAssert(m.insert(note: n, at: 0) == false, "Whole note doesn't fit in a 3/4 measure")
    }

    func testMeasure() {
        // test initialization
        var measure = Measure()
        let defaultKey = Key()
        XCTAssert(measure.key.mode == defaultKey.mode &&
            measure.key.fifths == defaultKey.fifths, "New Measure has a default Key")
        
        XCTAssert(measure.timeSignature == 4/4, "New measure has a default of 4/4 time")
        
        // test adding notes
        let A4quarter = Note(duration: .quarter, letter: .A, octave: 4)
        let B4quarter = Note(duration: .quarter, letter: .B, octave: 4)
        let C5eighth = Note(duration: .eighth, letter: .C, octave: 5)
        let D5quarter = Note(duration: .quarter, letter: .D, octave: 5)
        
        XCTAssert(measure.insert(note: A4quarter, at: 0) == true, "Note can be placed at start of free space")
        XCTAssert(measure.insert(note: B4quarter, at: 3/4) == true, "Note can be placed at end of free space")
        XCTAssert(measure.insert(note: C5eighth, at: 3/8) == true, "Note can be placed in the middle of free space")
        
        XCTAssert(measure.insert(note: D5quarter, at: 0) == false, "Notes can't be placed on another note")
        XCTAssert(measure.insert(note: D5quarter, at: 1/4) == false, "Notes can't be placed overlapping another note")
        
        // test directly accessing notes
        if let n0 = measure.getNote(at: 0) {
            XCTAssert(n0 == A4quarter, "Note can be accessed directly")
        } else {
            XCTFail("Note can be accessed directly")
        }
        if let n1 = measure.getNote(at: 3/8) {
            XCTAssert(n1 == C5eighth, "Note can be accessed directly")
        } else {
            XCTFail("Note can be accessed directly")
        }
        if let n2 = measure.getNote(at: 3/4) {
            XCTAssert(n2 == B4quarter, "Note can be accessed directly")
        } else {
            XCTFail("Note can be accessed directly")
        }
        
        // test getting all notes
        let notes = measure.getAllNotes()
        XCTAssert(notes.count == 3, "There are exactly 3 notes")
        XCTAssert(notes[0].pos == 0 && notes[0].note == A4quarter, "Note can be accessed")
        XCTAssert(notes[1].pos == 3/8 && notes[1].note == C5eighth, "Note can be accessed")
        XCTAssert(notes[2].pos == 3/4 && notes[2].note == B4quarter, "Note can be accessed")
        
        // test removing notes
        _ = measure.removeNote(at: 0)
        XCTAssert(measure.getAllNotes().count == 2, "There are exactly 2 notes after removing one")
        _ = measure.removeNote(at: 0)
        XCTAssert(measure.getAllNotes().count == 2, "Note cannot be removed twice")
        _ = measure.removeNote(at: 3/4)
        XCTAssert(measure.getAllNotes().count == 1, "There is only 1 note left")
        _ = measure.removeNote(at: 3/8)
        XCTAssert(measure.getAllNotes().count == 0, "There are no notes left")
    }
    
    func testNote() {
        let G4quarter = Note(duration: .quarter, letter: .G, octave: 4)
        XCTAssert(G4quarter.accidental == .natural, "Notes are natural by default")
        XCTAssert(G4quarter.rest == false, "Notes are not rest by default")
        XCTAssert(G4quarter.duration.rational == 1/4, "Quarter note == 1/4")
    }
    
    func testNoteView() {
        let C4 = NoteViewModel(note: Note(duration: .quarter, letter: .C, octave: 4), position: 0)
        XCTAssert(C4.pitch == -6, "C4 is 6 notes below centerline, on the first ledger line")
        var (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: -6)
        XCTAssert(letter == Note.Letter.C && octave == 4, "C4 is 6 notes below centerline, on the first ledger line")
        
        let A4 = NoteViewModel(note: Note(duration: .quarter, letter: .A, octave: 4), position: 0)
        XCTAssert(A4.pitch == -1, "A4 is 1 note below centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: -1)
        XCTAssert(letter == Note.Letter.A && octave == 4, "A4 is 1 note below centerline")
        
        let B4 = NoteViewModel(note: Note(duration: .quarter, letter: .B, octave: 4), position: 0)
        XCTAssert(B4.pitch == 0, "B4 is at the centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 0)
        XCTAssert(letter == Note.Letter.B && octave == 4, "B4 is at the centerline")
        
        let C5 = NoteViewModel(note: Note(duration: .quarter, letter: .C, octave: 5), position: 0)
        XCTAssert(C5.pitch == 1, "C5 is 1 note above centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 1)
        XCTAssert(letter == Note.Letter.C && octave == 5, "C5 is 1 note above centerline")
        
        let G5 = NoteViewModel(note: Note(duration: .quarter, letter: .G, octave: 5), position: 0)
        XCTAssert(G5.pitch == 5, "G5 is 5 notes above centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 5)
        XCTAssert(letter == Note.Letter.G && octave == 5, "G5 is 5 notes above centerline")
        
        let B5 = NoteViewModel(note: Note(duration: .quarter, letter: .B, octave: 5), position: 0)
        XCTAssert(B5.pitch == 7, "B5 is 7 notes above centerline, right above first ledger line")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 7)
        XCTAssert(letter == Note.Letter.B && octave == 5, "B5 is 7 notes above centerline, right above first ledger line")
    }
    
    func testKey() {
        let cMajor = Key()
        XCTAssert(cMajor.fifths == 0 && cMajor.mode == Key.Mode.major, "Key default initialization to C Major")
        
        let fsharpMajor = Key(mode: Key.Mode.major, fifths: 5)
        XCTAssert(fsharpMajor.getName() == "F♯M", "Major Key naming in circle of fifths")
        
        let bflatMinor = Key(mode: Key.Mode.minor, fifths: -5)
        XCTAssert(bflatMinor.getName() == "b♭m", "minor key naming in circle of fifths")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
