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
    
    // test for previous note with same letter
    func testMeasureGetPrevLetterMatch() {
        var measure = Measure()
        
        let A4quarter = Note(value: .quarter, letter: .A, octave: 4)
        let B4quarter = Note(value: .quarter, letter: .B, octave: 4)
        
        _ = measure.insert(note: A4quarter, at: 0)
        _ = measure.insert(note: A4quarter, at: 1/4)
        _ = measure.insert(note: B4quarter, at: 1/2)
        _ = measure.insert(note: A4quarter, at: 3/4)
        
        XCTAssert(measure.getPrevLetterMatch(for: .A, at: 0) == nil, "No same letter note before first note")
        if let match = measure.getPrevLetterMatch(for: .A, at: 1/4) {
            XCTAssert(match == A4quarter, "Finds the correct prev note")
        } else {
            XCTFail("Finds the correct prev note")
        }
        XCTAssert(measure.getPrevLetterMatch(for: .B, at: 1/2) == nil, "No same letter note")
        if let match = measure.getPrevLetterMatch(for: .A, at: 3/4) {
            XCTAssert(match == A4quarter, "Finds the correct prev note")
        } else {
            XCTFail("Finds the correct prev note")
        }
    }
    
    // test for changing the dot on a note
    func testMeasureDotNote() {
        var m = Measure()
        
        let _ = m.insert(note: Note(value: .eighth, letter: .A, octave: 4), at: 3/8)
        let _ = m.insert(note: Note(value: .quarter, letter: .A, octave: 4), at: 0)
        XCTAssert(m.dotNote(at: 0, dot: .single), "There is already enough space for dotted note")
        
        let _ = m.insert(note: Note(value: .eighth, letter: .A, octave: 4), at: 3/4)
        let _ = m.insert(note: Note(value: .quarter, letter: .A, octave: 4), at: 1/2)
        XCTAssert(m.dotNote(at: 1/2, dot: .single), "Neighbor is nudged to make space for dotted note")
        
        XCTAssert(m.dotNote(at: 0, dot: .none), "Able to remove dot")
        XCTAssert(m.frees[0].pos == 1/4 && m.frees[0].duration == 1/8, "Freespace created when dot is removed")        
    }
    
    func testNote() {
        let G4quarter = Note(value: .quarter, letter: .G, octave: 4)
        XCTAssert(G4quarter.accidental == .natural, "Notes are natural by default")
        XCTAssert(G4quarter.rest == false, "Notes are not rest by default")
        XCTAssert(G4quarter.duration == 1/4, "Quarter note == 1/4")
        G4quarter.dot = .single
        XCTAssert(G4quarter.duration == (1/4 * 3/2), "Quarter note with 1 dot")
        G4quarter.dot = .double
        XCTAssert(G4quarter.duration == (1/4 * 7/4), "Quarter note with 2 dots")
        G4quarter.dot = .none
        XCTAssert(G4quarter.duration == 1/4, "Quarter note with no dots")
    }
    
    func testKey() {
        let cMajor = Key() //default to C major
        let dMajor = Key(mode: .major, fifths: 2) //D major => 2 sharps
        let fMajor = Key(mode: .major, fifths: -1) //F major => 1 flat
        let cFlatMajor = Key(mode: .major, fifths: -7) //C flat major => 7 flats
        let cSharpMajor = Key(mode: .major, fifths: 7) //C sharp major => 7 sharps
        
        XCTAssert(cMajor.fifths == 0 && cMajor.mode == Key.Mode.major, "Key default initialization to C Major")
        
        let A = Note(value: .quarter, letter: .A, octave: 5)
        let B = Note(value: .quarter, letter: .B, octave: 5)
        let C = Note(value: .quarter, letter: .C, octave: 5)
        let D = Note(value: .quarter, letter: .D, octave: 5)
        let E = Note(value: .quarter, letter: .E, octave: 5)
        let F = Note(value: .quarter, letter: .F, octave: 5)
        let G = Note(value: .quarter, letter: .G, octave: 5)
        var allNotes = [Note]()
        allNotes.append(A)
        allNotes.append(B)
        allNotes.append(C)
        allNotes.append(D)
        allNotes.append(E)
        allNotes.append(F)
        allNotes.append(G)
        
        // check C major for no key hits
        for note in allNotes {
            XCTAssert(cMajor.keyHit(currentNoteLetter: note.letter) == nil, "Improper key hit on cMajor. Letter: " + String(describing: note.letter))
        }
        
        // check D major for key hits
        for note in allNotes {
            // should have keyHits for F and C (and they should return sharps) for D Major
            if(note == F || note == C) {
                XCTAssert(dMajor.keyHit(currentNoteLetter: note.letter) == Note.Accidental.sharp,
                          "Improper keyHit returned for D Major. Letter: " + String(describing: note.letter) + " returned: "
                           + dMajor.keyHit(currentNoteLetter: note.letter).debugDescription) // D major => F sharp key hit
            }
            // make sure keyHit returning nil for all other letters for D Major
            else {
                XCTAssert(dMajor.keyHit(currentNoteLetter: note.letter) == nil,
                          "Improper keyHit returned for D Major. Letter: " + String(describing: note.letter) + " returned: "
                           + dMajor.keyHit(currentNoteLetter: note.letter).debugDescription)
            }
        }
        
        // check F major for key hits
        for note in allNotes {
            // F major => B flat key hit
            if(note == B) {
                XCTAssert(fMajor.keyHit(currentNoteLetter: note.letter) == Note.Accidental.flat,
                          "Improper keyHit returned for F major. Letter: " + String(describing: note.letter) + " returned"
                          + fMajor.keyHit(currentNoteLetter: note.letter).debugDescription) // F major => B flat key hit
            }
            // make sure keyHit returning nil for all other letters for F Major
            else {
                XCTAssert(fMajor.keyHit(currentNoteLetter: note.letter) == nil,
                          "Improper keyHit returned for F major. Letter: " + String(describing: note.letter) + " returned"
                            + fMajor.keyHit(currentNoteLetter: note.letter).debugDescription) // F major => B flat key hit)
            }
        }
        
        // check C flat major for key hits
        for note in allNotes {
            XCTAssert(cFlatMajor.keyHit(currentNoteLetter: note.letter) == Note.Accidental.flat,
                      "Improper keyHit returned for C flat major. Letter: " + String(describing: note.letter) + " returned"
                        + fMajor.keyHit(currentNoteLetter: note.letter).debugDescription)
        }

        // check C sharp major for key hits
        for note in allNotes {
            XCTAssert(cSharpMajor.keyHit(currentNoteLetter: note.letter) == Note.Accidental.sharp,
                      "Improper keyHit returned for C sharp major. Letter: " + String(describing: note.letter) + " returned"
                        + fMajor.keyHit(currentNoteLetter: note.letter).debugDescription)
        }
    }
    
    func testGetAccidentalDisplay() {
        let cMajorScale = mockPart("CMajor")
        let dMajorScale = mockPart("DMajor")
        let dMajorRun = mockPart("DMajorRun")
        let kDeyTest = mockPart("KDeyTest")
        
        // test C major scale, key of C
        for measure in cMajorScale.measures {
            let mvm = MeasureViewModel(measure)
            for noteViewModel in mvm.notes {
                XCTAssert(noteViewModel.displayAccidental == false)
            }
        }
        
        // test D major scale, key of C
        for measure in dMajorScale.measures {
            let mvm = MeasureViewModel(measure)
            for noteViewModel in mvm.notes {
                if(noteViewModel.note.letter == Note.Letter.F || noteViewModel.note.letter == Note.Letter.C) {
                    XCTAssert(noteViewModel.displayAccidental == true)
                }
                else {
                    XCTAssert(noteViewModel.displayAccidental == false)
                }
            }
        }
        
        // test D major run, key of C
        for index in 0..<dMajorRun.measures.count {
            print("measure: " + index.description)
            let mvm = MeasureViewModel(dMajorRun.measures[index])
            for noteIndex in 0..<mvm.notes.count {
                // first measure
                if(index == 0) {
                    if(noteIndex == 2) {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == true)
                    }
                    else {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == false)
                    }
                }
                // second measure
                else {
                    if(noteIndex == 0 || noteIndex == 4 || noteIndex == 5) {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == true)
                    }
                    else {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == false)
                    }
                }
            }
        }
        
        // test D major line, key of D
        for index in 0..<kDeyTest.measures.count {
            let mvm = MeasureViewModel(kDeyTest.measures[index])
            for noteIndex in 0..<mvm.notes.count {
                // first measure
                if(index == 0) {
                    if(noteIndex == 6) {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == true)
                    }
                    else {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == false)
                    }
                }
                // second measure
                else {
                    if(noteIndex == 1 || noteIndex == 5 || noteIndex == 6) {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == true)
                    }
                    else {
                        XCTAssert(mvm.notes[noteIndex].displayAccidental == false) 
                    }
                }
            }
        }
    }

    func note(_ value: Note.Value) -> Note {
        return Note(value: value, letter: .A, octave: 4)
    }

    func testMocks() {
        let cMajorScale = mockPart("CMajor")
        XCTAssert(cMajorScale.measures.count == 3, "expected measure count: 3 actual: " + String(cMajorScale.measures.count))
        let dMajorScale = mockPart("DMajor")
        XCTAssert(dMajorScale.measures.count == 3, "expected measure count: 3 actual: " + String(dMajorScale.measures.count))
        let dMajorRun = mockPart("DMajorRun")
        XCTAssert(dMajorRun.measures.count == 2, "expected measure count: 2 actual: " + String(dMajorRun.measures.count))
        let KeyDTest = mockPart("KeyDTest")
        XCTAssert(KeyDTest.measures.count == 2)
        let beams = mockPart("BeamTest")
        XCTAssert(beams.measures.count == 3, "expected measure count: 3 actual: " + String(beams.measures.count))
    }

    func testSimpleMeasureInsertNudgeRight() {
        var mustNudgeRight = Measure()
        XCTAssert(mustNudgeRight.insert(note: note(.half), at: 0) != nil) // will be nudged to 1/4
        XCTAssert(mustNudgeRight.insert(note: note(.quarter), at: 7/10) != nil) // will be nudged to 3/4

        XCTAssert(mustNudgeRight.insert(note: note(.quarter), at: 0) != nil)

        XCTAssertEqual(mustNudgeRight.notes[0].pos, 0)
        XCTAssertEqual(mustNudgeRight.notes[1].pos, 1/4)
        XCTAssertEqual(mustNudgeRight.notes[2].pos, 3/4)
    }

    func testSimpleMeasureInsertNudgeLeft() {
        var m = Measure()
        XCTAssert(m.insert(note: note(.half), at: 1/2) != nil) // will remain in place
        XCTAssert(m.insert(note: note(.quarter), at: 1/4) != nil) // will be nudged to 0

        XCTAssert(m.insert(note: note(.quarter), at: 1/2) != nil)

        XCTAssertEqual(m.notes[0].pos, 0)
        XCTAssertEqual(m.notes[1].pos, 1/4)
        XCTAssertEqual(m.notes[2].pos, 1/2)
    }

    func testSimpleMeasureInsertion() {

        // insert a quarter note at 0 into a variety of measures. assert that it ends up where we expect

        let empty = Measure()

        var full = Measure()
        XCTAssert(full.insert(note: note(.whole), at: 0) != nil)

        var mustNudgeRight = Measure()
        XCTAssert(mustNudgeRight.insert(note: note(.half), at: 0) != nil)

        var mustNudgeLeft = Measure()
        XCTAssert(mustNudgeLeft.insert(note: note(.half), at: 2/4) != nil)

        typealias testCase = (measure: Measure, note: Note, position: Rational, expectedSuccess: Bool, expectedPosition: Rational?)
        let testCases: [testCase] = [
            (empty, note(.quarter), 0, true, 0),
            (full, note(.quarter), 0, false, 0),
            (mustNudgeRight, note(.quarter), 0, true, 0),
            (mustNudgeLeft, note(.quarter), 2/4, true, 1/4),
        ]

        for (i, c) in testCases.enumerated() {
            var m = c.measure
            let whereInserted = m.insert(note: c.note, at: c.position)
            XCTAssertEqual(c.expectedSuccess, whereInserted != nil, "\(i)")
            if c.expectedSuccess, let xp = c.expectedPosition {
                guard let n = m.note(at: xp) else {
                    XCTFail("\(i)")
                    return
                }
                XCTAssert(n == c.note, "\(i)")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
